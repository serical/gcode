package ${package_name}.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;

import ${package_name}.dao.${module_name}Dao;
import com.sks.common.util.FileDownloadUtils;

import net.sf.json.JSONObject;
import net.sf.jxls.transformer.XLSTransformer;

/**
 * @项目名称: ${project_name}
 * @类名称: ${module_name}Service
 * @类描述: ${name}service
 * @创建人: ${author}
 * @创建时间: ${date_time}
 * @修改人: ${author}
 * @修改时间: ${date_time}
 * @修改备注:
 * @version: 1.0
 */
public class ${module_name}Service {

	private final static Logger log = Logger.getLogger(${module_name}Service.class);

	/**
	 * 保存${name}
	 * 
	 * @方法名:save${module_name}
	 * @参数 @param map
	 * @参数 @return
	 * @返回类型 Object
	 */
	public Object save${module_name}(Map<String, String> map) {
		JSONObject json = new JSONObject();
		String id = map.get("${primary_key}");
		${module_name}Dao dao = new ${module_name}Dao();
		try {
			if (null != id && !"".equals(id)) {
				dao.update${module_name}(map);
			} else {
				dao.insert${module_name}(map);
			}

			json.put("status", "1");
			json.put("msg", "保存成功！");
		} catch (Exception e) {
			json.put("status", "0");
			json.put("msg", "保存失败！");
			e.printStackTrace();
			log.error("保存${name}出错！" + e.toString());
		}
		return json;
	}

	/**
	 * 删除${name}
	 * 
	 * @方法名:delete${module_name}
	 * @参数 @param map
	 * @参数 @return
	 * @返回类型 Object
	 */
	public Object delete${module_name}(Map<String, String> map) {
		JSONObject json = new JSONObject();
		${module_name}Dao dao = new ${module_name}Dao();
		try {
			dao.delete${module_name}(map);
			json.put("status", "1");
			json.put("msg", "删除成功！");
		} catch (Exception e) {
			json.put("status", "0");
			json.put("msg", "删除失败！");
			e.printStackTrace();
			log.error("删除${name}出错！" + e.toString());
		}
		return json;
	}

	/**
	 * 查询${name}
	 * 
	 * @方法名:get${module_name}List
	 * @参数 @param map
	 * @参数 @return
	 * @返回类型 Object
	 */
	@SuppressWarnings("rawtypes")
	public Object get${module_name}List(Map<String, String> map) {
		JSONObject json = new JSONObject();
		${module_name}Dao dao = new ${module_name}Dao();
		try {
			List<HashMap> list = dao.get${module_name}List(map);
			json.put("total", list.size());
			json.put("rows", list);
			return json;
		} catch (Exception e) {
			e.printStackTrace();
			log.error("查询${name}出错！" + e.toString());
			return "[]";
		}
	}

	/**
	 * 按ID查询${name}
	 * 
	 * @方法名:get${module_name}ById
	 * @参数 @param id
	 * @参数 @return
	 * @返回类型 Object
	 */
	public Object get${module_name}ById(String id) {
		${module_name}Dao dao = new ${module_name}Dao();
		try {
			return dao.get${module_name}ById(id);
		} catch (Exception e) {
			e.printStackTrace();
			log.error("按ID查询${name}出错！" + e.toString());
			return null;
		}
	}
	
	/**
	 * 导出${name}
	 * 
	 * @param response
	 * @param map
	 */
	@SuppressWarnings("rawtypes")
	public void export${module_name}(HttpServletResponse response, Map<String, String> map) {
		String fileName = "${name}";
		${module_name}Dao dao = new ${module_name}Dao();
		try {
			String templateFileName = FileDownloadUtils.getTemplatePath() + "/${table_name?lower_case}.xls";
			String destFileName = FileDownloadUtils.getOutputPath() + "/${table_name?lower_case}_output.xls";
			List<HashMap> list = dao.get${module_name}List(map);
			Map<String, List<HashMap>> beans = new HashMap<String, List<HashMap>>();
			beans.put("beanList", list);

			XLSTransformer transformer = new XLSTransformer();
			transformer.transformXLS(templateFileName, beans, destFileName);
			FileDownloadUtils.downLoadFile(destFileName, response, fileName, "xls");
		} catch (Exception e) {
			log.error("导出${name}出错！" + e.toString());
			e.printStackTrace();
		}
	}
}
