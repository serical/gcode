package com.sks.gcode;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.nio.file.DirectoryStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.commons.codec.digest.DigestUtils;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.time.DateFormatUtils;

public class GeneratePatcher {

	// 项目名
	private static String project_name = "ld_crm";
	// web上下文
	private static String web_path = "WebRoot";
	// eclipse的workspace路径
	private static String workspace_path = "D:\\workspace\\javaee";
	// 部署包临时路径
	private static String temp_dir = "D:\\patcher";

	private static String deply_path = workspace_path + File.separator + project_name + File.separator + web_path;
	private static String temp_path = temp_dir + File.separator + project_name;
	private static String desktop_path = System.getProperty("user.home") + File.separator + "Desktop" + File.separator
			+ DateFormatUtils.format(new Date(), "yyyyMMdd") + File.separator + web_path + File.separator;
	private static List<String> change_list = new ArrayList<>();
	private static boolean first = false;

	public static void main(String[] args) {
		Path path = Paths.get(temp_path);
		try {
			// 如果是第一次则不生成补丁
			if (Files.notExists(path)) {
				first = true;
			}

			// 检测临时目录
			checkDirectory(path);

			// 处理任务
			list(Paths.get(deply_path));

			// 结果
			if (first) {
				System.out.println("同步临时区文件完成！");
			} else {
				System.out.println("改动文件总数：" + change_list.size());
				if (change_list.size() > 0) {
					for (String str : change_list) {
						System.out.println(str);
					}
				}
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * 检测路径是否存在，不存在则创建
	 * 
	 * @param path
	 * @throws IOException
	 */
	public static void checkDirectory(Path path) throws IOException {
		if (Files.notExists(path)) {
			Files.createDirectories(path);
			// Files.setAttribute(path, "dos:hidden", true, LinkOption.NOFOLLOW_LINKS);
		}
	}

	/**
	 * 递归检测改动
	 * 
	 * @param dir
	 * @throws IOException
	 */
	public static void list(Path dir) throws IOException {
		DirectoryStream<Path> stream = Files.newDirectoryStream(dir);
		for (Path path : stream) {
			if (Files.isDirectory(path)) {
				list(path);
			} else {
				String relative_path = path.toAbsolutePath().toString().replace(deply_path, "");
				Path temp_file = Paths.get(temp_path + relative_path);
				if (Files.notExists(temp_file)) {
					generatePathcer(path, temp_file, relative_path);
				} else {
					String source_md5 = DigestUtils.md5Hex(new FileInputStream(path.toAbsolutePath().toFile()));
					String temp_md5 = DigestUtils.md5Hex(new FileInputStream(temp_file.toAbsolutePath().toFile()));
					if (!source_md5.equals(temp_md5)) {
						generatePathcer(path, temp_file, relative_path);
					}
				}
			}
		}
	}

	/**
	 * 生成补丁、更新临时区
	 * 
	 * @param path
	 * @param temp_file
	 * @param relative_path
	 * @throws IOException
	 */
	public static void generatePathcer(Path path, Path temp_file, String relative_path) throws IOException {
		// 文件名
		String file_name = path.getFileName().toString();
		// 检测临时路径是否存在
		Path temp_dir = Paths.get(temp_file.toString().replace(file_name, ""));
		checkDirectory(temp_dir);

		// nio方式：java.nio.file.FileSystemException: 另一个程序正在使用此文件，进程无法访问。
		// Files.copy(path, temp_file, StandardCopyOption.REPLACE_EXISTING);
		// Files.copy(path, patcher_path, StandardCopyOption.REPLACE_EXISTING);
		// 更新临时区同步
		FileUtils.copyFile(path.toFile(), temp_file.toFile());
		// 生成补丁
		if (!first) {
			// 检测补丁路径目录是否存在
			Path patcher_path = Paths.get(desktop_path + relative_path);
			Path pathcer_dir = Paths.get(patcher_path.toString().replace(file_name, ""));
			checkDirectory(pathcer_dir);

			FileUtils.copyFile(path.toFile(), patcher_path.toFile());
			// 改动list
			change_list.add(path.toAbsolutePath().toString());
		}
	}
}
