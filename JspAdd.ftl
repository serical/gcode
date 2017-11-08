<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- ${name}添加 --%>
<html>
<head>
    <%@include file="/common/referenceFile.jsp" %>
    <script type="text/javascript" src="${'$'}{path}/js/privileges.js"></script>

    <script type="text/javascript">
        $(function () {
        	// 初始下拉
        	initCombo();
        });
        
        /**初始化下拉*/
        function initCombo() {
        	
        }

        /**检测提交form*/
        function checkSubmit() {
            ${'$'}("#addForm").form("submit", {
                url: "${'$'}{path}/${mn}/save${module_name}.do",
                onSubmit: function (param) {
                    if (!$("#addForm").form("validate")) {
                        return false;
                    }
                },
                success: function (data) {
                    parent.closeDialog(data);
                }
            });
        }
    </script>
</head>

<body>
<form id="addForm" action="" method="post">
    <table class="Ctable" width="100%">
    	<#list all_columns as item>
        <tr>
            <td class="c10" width="35%">${item.name}：</td>
            <td class="category">
	            <input id="${item.field_name}" name="${item.field_name}" class="easyui-${item.easyui_type}" value="${'$'}{bean.${item.field_name}}"
                       data-options="required:${required!'true'}">
            </td>
        </tr>
        </#list>
    </table>
    <input id="${primary_key}" name="${primary_key}" type="hidden" value="${'$'}{bean.${primary_key}}">
</form>
</body>
</html>
