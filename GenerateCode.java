package com.sks.gcode;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.time.DateFormatUtils;
import org.apache.commons.lang3.StringUtils;

import com.frameworkset.common.poolman.DBUtil;
import com.frameworkset.common.poolman.sql.ColumnMetaData;
import com.frameworkset.common.poolman.sql.PrimaryKeyMetaData;
import com.frameworkset.common.poolman.sql.TableMetaData;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateExceptionHandler;

@SuppressWarnings("unchecked")
public class GenerateCode {

	// 个性化配置
	private static String project_name = "ldcrm";
	private static String author = "serical";
	private static String package_name = "com.business.test";
	private static String module_name = "TestInfo";
	private static String jsp_path = "test";
	// 需要生成的表名
	private static String table_name = "TB_TEST";
	// 查询列声明，与数据库字段相同，必须大写
	private static String[] querys = new String[] { "TEST_NAME", "TEST_DATE" };

	// table配置
	private static Map<String, Object> table = new HashMap<>();
	// columns配置
	private static List<Map<String, String>> all_columns = new ArrayList<>();
	// 查询列数据
	private static List<Map<String, String>> query_columns = new ArrayList<>();

	static {
		table.put("project_name", project_name);
		table.put("author", author);
		table.put("package_name", package_name);
		table.put("module_name", module_name);
		table.put("jsp_path", jsp_path);
		// jsp首字母小写
		String mn = module_name.substring(0, 1).toLowerCase() + module_name.substring(1);
		table.put("mn", mn);

		// 读取数据库表信息
		TableMetaData tmd = DBUtil.getTableMetaData(table_name);
		table.put("table_name", tmd.getTableName());
		table.put("name", StringUtils.isEmpty(tmd.getRemarks()) ? tmd.getTableName() : tmd.getRemarks());

		// 处理主键
		String primary_key = "";
		Set<PrimaryKeyMetaData> primary_keys = tmd.getPrimaryKeys();
		if (null != primary_keys && primary_keys.size() > 0) {
			for (PrimaryKeyMetaData p : primary_keys) {
				primary_key = p.getColumnName();
				break;
			}
		} else {
			System.out.println(table.get("table_name") + "没有主键！");
			System.exit(0);
		}
		table.put("primary_key", primary_key);

		// 组装columns
		Set<ColumnMetaData> cmd = tmd.getColumns();
		if (null != cmd && cmd.size() > 0) {
			Set<String> query_set = new HashSet<>(Arrays.asList(querys));
			for (ColumnMetaData c : cmd) {
				if (!primary_key.equals(c.getColumnName())) {
					Map<String, String> column = new HashMap<>();
					column.put("name", StringUtils.isEmpty(c.getRemarks()) ? c.getColumnName() : c.getRemarks());
					column.put("field_name", c.getColumnName());
					// 类型
					String field_type = "";
					String easyui_type = "";
					String type_name = c.getTypeName();
					if ("DATE".equals(type_name)) {
						field_type = "DATE";
						easyui_type = "datebox";
					} else if ("NUMBER".equals(type_name)) {
						field_type = "NUMBER";
						easyui_type = "numberbox";
					} else {
						field_type = "VARCHAR";
						easyui_type = "textbox";
					}
					column.put("field_type", field_type);
					column.put("easyui_type", easyui_type);
					// 是否必填
					if ("NO".equals(c.getNullable())) {
						column.put("required", "true");
					} else {
						column.put("required", "false");
					}

					// 所有列
					all_columns.add(column);
					// 查询列
					if (null != query_set && query_set.size() > 0) {
						if (query_set.contains(c.getColumnName())) {
							query_columns.add(column);
						}
					}
				}
			}
		}

		table.put("all_columns", all_columns);
		table.put("query_columns", query_columns);
	}

	public static void main(String[] args) {
		generateCode();
	}

	/**
	 * 生成代码
	 */
	public static void generateCode() {
		Writer daoOut = null;
		Writer serviceOut = null;
		Writer actionOut = null;
		Writer listOut = null;
		Writer addOut = null;
		Writer xlsOut = null;
		try {
			// freemarker配置
			Configuration cfg = new Configuration(Configuration.VERSION_2_3_26);
			cfg.setDirectoryForTemplateLoading(new File(GenerateCode.class.getResource("").getPath()));
			cfg.setDefaultEncoding("UTF-8");
			cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
			cfg.setLogTemplateExceptions(false);

			// 路径配置
			String path = System.getProperty("user.home") + File.separator + "Desktop" + File.separator
					+ table.get("name") + File.separator;
			String package_path = path + package_name.replace(".", File.separator) + File.separator;
			String jsp_path = path + "WEB-INF" + File.separator + "jsp" + File.separator + "business" + File.separator
					+ table.get("jsp_path") + File.separator;

			// 生成dao
			Template t = cfg.getTemplate("JavaDao.ftl");
			String insert_field = "";
			String insert_value = "";
			List<String> update_list = new ArrayList<>();
			String select_list = "";
			if (null != all_columns && all_columns.size() > 0) {
				for (int i = 0; i < all_columns.size(); i++) {
					Map<String, String> m = all_columns.get(i);
					String field_name = m.get("field_name").toString();
					String field_type = m.get("field_type").toString();

					insert_field += field_name;
					insert_value += "DATE".equals(field_type) ? "TO_DATE(#[" + field_name + "], 'YYYY-MM-DD')"
							: "#[" + field_name + "]";
					String update = field_name + " = "
							+ ("DATE".equals(field_type) ? "TO_DATE(#[" + field_name + "], 'YYYY-MM-DD')"
									: "#[" + field_name + "]");
					select_list += "DATE".equals(field_type)
							? "TO_CHAR(T." + field_name + ", 'YYYY-MM-DD') AS " + field_name
							: "T." + field_name;
					if (i < all_columns.size() - 1) {
						insert_field += ", ";
						insert_value += ", ";
						update += ",";
						select_list += ", ";
					}
					update_list.add(update);
				}
			}
			table.put("insert_field", insert_field);
			table.put("insert_value", insert_value);
			table.put("update_list", update_list);
			table.put("select_list", select_list);
			table.put("date_time", DateFormatUtils.format(new Date(), "yyyy-MM-dd HH:mm:ss"));

			File daoFile = new File(package_path + "dao");
			daoFile.mkdirs();
			daoOut = new OutputStreamWriter(
					new FileOutputStream(daoFile.getAbsolutePath() + File.separator + module_name + "Dao.java"),
					"UTF-8");
			t.process(table, daoOut);

			// 生成service
			t = cfg.getTemplate("JavaService.ftl");
			File serviceFile = new File(package_path + "service");
			serviceFile.mkdirs();
			serviceOut = new OutputStreamWriter(
					new FileOutputStream(serviceFile.getAbsolutePath() + File.separator + module_name + "Service.java"),
					"UTF-8");
			t.process(table, serviceOut);

			// 生成action
			t = cfg.getTemplate("JavaAction.ftl");
			File actionFile = new File(package_path + "action");
			actionFile.mkdirs();
			actionOut = new OutputStreamWriter(
					new FileOutputStream(actionFile.getAbsolutePath() + File.separator + module_name + "Action.java"),
					"UTF-8");
			t.process(table, actionOut);

			// 生成list.jsp
			File jspFile = new File(jsp_path);
			jspFile.mkdirs();
			t = cfg.getTemplate("JspList.ftl");
			listOut = new OutputStreamWriter(
					new FileOutputStream(jspFile.getAbsolutePath() + File.separator + table.get("mn") + "List.jsp"),
					"UTF-8");
			t.process(table, listOut);

			// 生成add.jsp
			t = cfg.getTemplate("JspAdd.ftl");
			addOut = new OutputStreamWriter(
					new FileOutputStream(jspFile.getAbsolutePath() + File.separator + table.get("mn") + "Add.jsp"),
					"UTF-8");
			t.process(table, addOut);

			// 生成xls导出模板
			t = cfg.getTemplate("Xls.ftl");
			xlsOut = new OutputStreamWriter(new FileOutputStream(new File(path).getAbsolutePath() + File.separator
					+ table.get("table_name").toString().toLowerCase() + ".xls"), "UTF-8");
			t.process(table, xlsOut);

		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			try {
				daoOut.close();
				serviceOut.close();
				actionOut.close();
				listOut.close();
				addOut.close();
				xlsOut.close();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
	}
}