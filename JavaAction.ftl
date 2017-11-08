package ${package_name}.action;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.sks.common.util.RequestParamUtil;
import ${package_name}.service.${module_name}Service;

/**
 * @项目名称: ${project_name}
 * @类名称: ${module_name}Action
 * @类描述: ${name}action
 * @创建人: ${author}
 * @创建时间: ${date_time}
 * @修改人: ${author}
 * @修改时间: ${date_time}
 * @修改备注:
 * @version: 1.0
 */
@Controller
@RequestMapping("/${mn}")
public class ${module_name}Action {

	/** 跳转${name} */
	@RequestMapping("/to${module_name}List")
	public Object to${module_name}List() {
		return "WEB-INF/jsp/business/${jsp_path}/${mn}List";
	}

	/** 跳转${name}添加 */
	@RequestMapping("/to${module_name}Add")
	public Object to${module_name}Add(HttpServletRequest request, ModelMap model) {
		${module_name}Service service = new ${module_name}Service();
		String id = request.getParameter("${primary_key}");
		if (null != id && !"".equals(id)) {
			model.addAttribute("bean", service.get${module_name}ById(id));
		}
		return "WEB-INF/jsp/business/${jsp_path}/${mn}Add";
	}

	/** 删除${name} */
	@ResponseBody
	@RequestMapping("/save${module_name}")
	public Object save${module_name}(HttpServletRequest request) {
		${module_name}Service service = new ${module_name}Service();
		return service.save${module_name}(RequestParamUtil.handleParamToMap(request));
	}

	/** 保存${name} */
	@ResponseBody
	@RequestMapping("/delete${module_name}")
	public Object delete${module_name}(HttpServletRequest request) {
		${module_name}Service service = new ${module_name}Service();
		return service.delete${module_name}(RequestParamUtil
				.handleParamToMap(request));
	}

	/** 查询${name} */
	@ResponseBody
	@RequestMapping("/get${module_name}List")
	public Object get${module_name}List(HttpServletRequest request) {
		${module_name}Service service = new ${module_name}Service();
		return service.get${module_name}List(RequestParamUtil
				.handleParamToMap(request));
	}
	
	/** 导出${name} */
	@RequestMapping("/export${module_name}")
	public void export${module_name}(HttpServletRequest request, HttpServletResponse response) {
		${module_name}Service service = new ${module_name}Service();
		service.export${module_name}(response, RequestParamUtil.handleParamToMap(request));
	}
}
