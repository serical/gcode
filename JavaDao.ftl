package ${package_name}.dao;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.frameworkset.common.poolman.SQLExecutor;

/**
 * @项目名称: ${project_name}
 * @类名称: ${module_name}Dao
 * @类描述: ${name}dao
 * @创建人: ${author}
 * @创建时间: ${date_time}
 * @修改人: ${author}
 * @修改时间: ${date_time}
 * @修改备注:
 * @version: 1.0
 */
public class ${module_name}Dao {

	/**
	 * 插入${name}
	 * 
	 * @方法名:insert${module_name}
	 * @参数 @param map
	 * @参数 @throws SQLException
	 * @返回类型 void
	 */
	public void insert${module_name}(Map<String, String> map) throws SQLException {
		StringBuffer sb = new StringBuffer();
		sb.append("INSERT INTO ${table_name} ");
		sb.append("(${primary_key}, ${insert_field}) ");
		sb.append("VALUES ");
		sb.append("(SEQ_${table_name}.NEXTVAL, ${insert_value}) ");

		SQLExecutor.insertBean(sb.toString(), map);
	}

	/**
	 * 删除${name}
	 * 
	 * @方法名:delete${module_name}
	 * @参数 @param map
	 * @参数 @throws SQLException
	 * @返回类型 void
	 */
	public void delete${module_name}(Map<String, String> map) throws SQLException {
		SQLExecutor.deleteBean("DELETE ${table_name} WHERE ${primary_key} = #[${primary_key}]", map);
	}

	/**
	 * 更新${name}
	 * 
	 * @方法名:update${module_name}
	 * @参数 @param map
	 * @参数 @throws SQLException
	 * @返回类型 void
	 */
	public void update${module_name}(Map<String, String> map) throws SQLException {
		StringBuffer sb = new StringBuffer();
		sb.append("UPDATE ${table_name} ");
		sb.append("SET ");
		<#list update_list as update>
		sb.append("${update} ");
		</#list>
		sb.append("WHERE ${primary_key} = #[${primary_key}] ");

		SQLExecutor.updateBean(sb.toString(), map);
	}

	/**
	 * 查询${name}
	 * 
	 * @方法名:get${module_name}List
	 * @参数 @param map
	 * @参数 @return
	 * @参数 @throws SQLException
	 * @返回类型 List<HashMap>
	 */
	@SuppressWarnings("rawtypes")
	public List<HashMap> get${module_name}List(Map<String, String> map)
			throws SQLException {
		StringBuffer sb = new StringBuffer();
		sb.append("SELECT T.${primary_key}, ${select_list} ");
		sb.append("FROM ${table_name} T ");
		sb.append("WHERE 1=1 ");
		<#list query_columns as query>
		if (null != map.get("${query.field_name}") && !"".equals(map.get("${query.field_name}"))) {
			<#if query.field_type?index_of("DATE") != -1>
			sb.append("AND ${query.field_name} = TO_DATE('" + map.get("${query.field_name}") + "', 'YYYY-MM-DD') ");
			<#elseif query.field_type?index_of("NUMBER") != -1>
			sb.append("AND ${query.field_name} = " + map.get("${query.field_name}") + " ");
			<#else >
			sb.append("AND ${query.field_name} = '" + map.get("${query.field_name}") + "' ");
			</#if>
		}
		</#list>
		sb.append("ORDER BY T.${primary_key} DESC ");

		return SQLExecutor.queryList(HashMap.class, sb.toString());
	}

	/**
	 * 按ID查询${name}
	 * 
	 * @方法名:get${module_name}ById
	 * @参数 @param id
	 * @参数 @return
	 * @参数 @throws SQLException
	 * @返回类型 List<HashMap>
	 */
	@SuppressWarnings("rawtypes")
	public HashMap get${module_name}ById(String id) throws SQLException {
		StringBuffer sb = new StringBuffer();
		sb.append("SELECT ${primary_key}, ${insert_field} ");
		sb.append("FROM ${table_name} ");
		sb.append("WHERE ${primary_key} = ?");

		return SQLExecutor.queryObject(HashMap.class, sb.toString(), id);
	}
}
