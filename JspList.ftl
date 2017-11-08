<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%-- ${name}列表 --%>
<html>
<head>
    <%@include file="/common/referenceFile.jsp" %>
    <script type="text/javascript" src="${'$'}{path}/js/privileges.js"></script>
    
    <script type="text/javascript">
        $(function () {
        
        	// 初始下拉
        	initCombo();
        
        	// 初始化数据表格
            initDatagrid(getQueryParams());
        });
        
        /**初始化下拉*/
        function initCombo() {
        	
        }

        /**获取查询参数*/
        function getQueryParams() {
            var param = {};
            <#list query_columns as query>
        	param.${query.field_name} = $("#${query.field_name}").${query.easyui_type}("getValue");
        	</#list>

            return param;
        }

        /**初始化下拉*/
        function initDatagrid(param) {
            $("#dg").datagrid({
                idField: "${primary_key}",
                title: "${name}列表",
                url: "${'$'}{path}/${mn}/get${module_name}List.do",
                loadMsg: '数据装载中......',
                queryParams: param,
                rownumbers: true,
                fit: true,
                fitColumns: true,
                singleSelect: true,
                border: false,
                striped: true,
                //pagination: true,
                //pageSize : 20,
                //pageList: [10, 20, 40, 60],
                toolbar: [{
                    text: "新增",
                    iconCls: "icon-add",
                    handler: function () {
                        $("#addDialog").dialog({
                            title: "添加${name}",
                            width: 700,
                            height: 450,
                            modal: true,
                            buttons: [{
                                text: "保存",
                                iconCls: "icon-ok",
                                handler: function (e) {
                                    // 调用子窗口方法验证
                                    var result = $("#addFrame")[0].contentWindow.checkSubmit();
                                    if (result == false) {
                                        return;
                                    }
                                }
                            }, {
                                text: "取消",
                                iconCls: "icon-cancel",
                                handler: function (e) {
                                    $("#addDialog").dialog("close");
                                }
                            }]
                        });
                        ${'$'}("#addFrame").attr("src", "${'$'}{path}/${mn}/to${module_name}Add.do");
                    }
                }, {
                    text: "修改",
                    iconCls: "icon-edit",
                    handler: function () {
                        var row = $("#dg").datagrid("getSelected");
                        if (!row) {
                            $.messager.alert("系统提示", "请选择一条记录！", "error");
                            return;
                        }
                        $("#addDialog").dialog({
                            title: "修改${name}",
                            width: 700,
                            height: 450,
                            modal: true,
                            buttons: [{
                                text: "保存",
                                iconCls: "icon-ok",
                                handler: function (e) {
                                    // 调用子窗口方法验证
                                    var result = $("#addFrame")[0].contentWindow.checkSubmit();
                                    if (result == false) {
                                        return;
                                    }
                                }
                            }, {
                                text: "取消",
                                iconCls: "icon-cancel",
                                handler: function (e) {
                                    $("#addDialog").dialog("close");
                                }
                            }]
                        });
                        ${'$'}("#addFrame").attr("src", "${'$'}{path}/${mn}/to${module_name}Add.do?${primary_key}=" + row.${primary_key});
                    }
                }, {
                    text: "删除",
                    iconCls: "icon-remove",
                    handler: function () {
                        var row = $("#dg").datagrid("getSelected");
                        if (!row) {
                            $.messager.alert("系统提示", "请选择一条记录！", "error");
                            return;
                        }
                        $.messager.confirm("系统提示", "是否确认删除该记录？", function (r) {
                            if (r) {
                                ${'$'}.ajax({
                                    url: "${'$'}{path}/${mn}/delete${module_name}.do",
                                    data: {${primary_key}: row.${primary_key}},
                                    type: "post",
                                    dataType: "json",
                                    success: function (data) {
                                        if (data.status == "1") {
                                            $.messager.alert("系统提示", data.msg, "info");
                                            $("#dg").datagrid("reload");
                                        } else if (data.status == "0" || data.status == "2") {
                                            $.messager.alert("系统提示", data.msg, "error");
                                        }
                                    }
                                });
                            }
                        });
                    }
                }],
                columns: [[
                <#list all_columns as item>
	                {
	                    title: "${item.name}",
	                    field: "${item.field_name}",
	                    align: "center",
	                    width: 100
	                }<#if (item_has_next)>,</#if>
	            </#list>
                ]]
            });
        }

        /**查询事件*/
        function searchEvent() {
            $("#dg").datagrid("load", getQueryParams());
        }

        /**重置事件*/
        function resetEvent() {
        	<#list query_columns as query>
        	$("#${query.field_name}").${query.easyui_type}("setValue", "");
        	</#list>
            searchEvent();
        }

        /**子窗口保存后回调*/
        function closeDialog(data) {
            $("#addDialog").dialog("close");
            var o = $.parseJSON(data);
            if (o.status == "1") {
                $.messager.alert("系统提示", o.msg, "info");
                $("#dg").datagrid("reload");
            } else if (o.status == "0" || o.status == "2") {
                $.messager.alert("系统提示", o.msg, "error");
            }
        }
        
        /**导出事件*/
    	function exportEvent() {
    		var param = getQueryParams();
    		var str = changeParamToStr(param);
    		$.messager.confirm("系统提示","是否确认导出？",function(r) {
    			if (r) {
    				window.location.href = "${'$'}{path}/${mn}/export${module_name}.do"+str;
    			} 
    		});
    	}
    </script>

</head>

<body class="easyui-layout">
<!-- 查询条件 -->
<div data-options="region:'north'" style="height:72px">
    <table class="Ctable" width="100%">
        <tr>
    	<#list query_columns as query>
        	<td class="c10">${query.name}：</td>
            <td class="category">
	            <input id="${query.field_name}" class="easyui-${query.easyui_type}">
            </td>
        </#list>
        </tr>
    </table>
    <div style="text-align: center;">
        <a href="javascript:void(0)" onclick="searchEvent()" class="easyui-linkbutton"
           data-options="iconCls:'icon-search'">查询</a>
        <a href="javascript:void(0)" onclick="resetEvent()" class="easyui-linkbutton"
           data-options="iconCls:'icon-reload'">重置</a>
		<a href="javascript:void(0)" onclick="exportEvent()"class="easyui-linkbutton" 
		   data-options="iconCls:'icon-redo'">导出</a>
    </div>
</div>

<!-- 数据表格 -->
<div data-options="region:'center'">
    <table id="dg"></table>
</div>

<!-- 添加,修改界面 -->
<div id="addDialog">
    <iframe id="addFrame" name="addFrame" scrolling="auto" width="100%" height="98%" frameborder="0"></iframe>
</div>
</body>
</html>