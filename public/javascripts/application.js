// 公共JS
var Common = {
    //提示框效果
    executeTooltips: function() {
	$(".tip_trigger").hover(function(){
	    tip = $(this).find('.tip');
	    tip.show(); //Show tooltip
	}, function() {
	    tip.hide(); //Hide tooltip
	}).mousemove(function(e) {
	    var mousex = e.pageX + 20; //Get X coodrinates
	    var mousey = e.pageY + 20; //Get Y coordinates
	    var tipWidth = tip.width(); //Find width of tooltip
	    var tipHeight = tip.height(); //Find height of tooltip

	    //Distance of element from the right edge of viewport
	    var tipVisX = $(window).width() - (mousex + tipWidth);
	    //Distance of element from the bottom of viewport
	    var tipVisY = $(window).height() - (mousey + tipHeight);

	    if ( tipVisX < 20 ) { //If tooltip exceeds the X coordinate of viewport
		mousex = e.pageX - tipWidth - 20;
	    }
	    if ( tipVisY < 20 ) { //If tooltip exceeds the Y coordinate of viewport
		mousey = e.pageY - tipHeight - 20;
	    }
	    //Absolute position the tooltip according to mouse position
	    tip.css({
		top: mousey,
		left: mousex
	    });
	});
    },
    //内容加载前，显示等待图片
    showRoller: function(area) {
	$(area).empty();
	$(area).append('<img src="/images/roller.gif" style="width: 22px; vertical-align: middle;" />');
    },
    //内容加载完成后，删除等待图片
    removeRoller: function(area) {
	$(area).empty();
    },
    //全选与全不选功能
    selectAll: function(checkbox){
	$(":checkbox").each(function(){
	    $(checkbox).is(":checked") ? $(this).attr("checked","checked") : $(this).removeAttr("checked");
	})
    },
    //收集被选中项目的value值，用“,”隔开
    collectIds: function(checkedboxs) {
	var ids = '';
	checkedboxs.each(function(){
	    if (ids != '')
		ids = ids + ',';
	    ids = ids + $(this).val();
	});
	return ids;
    },
    //批量删除功能
    batchDelete: function(klass, checkedboxs) {
	var ids = this.collectIds(checkedboxs); //收集id
	if (ids == '') {
	    alert('你还没有选中任何项目!');
	} else {
	    $.ajax({
		type: 'POST',
		url: '/utilities/batch_delete',
		data: {
		    klass: klass,
		    ids: ids
		},
		success: function(msg) {
		    if (msg != 'OK')
			alert(msg);
		    checkedboxs.each(function(){
			$("#tr_" + $(this).val()).remove();
		    });
		},
		error: function(){
		    alert('删除失败! 请联系管理员! ')
		}
	    })
	}
    },
    //获取url上“#”后面的参数
    getFlagFromUrl: function() {
	return window.location.href.split('#')[1]
    },
    // 复制到剪贴板，不支持谷歌浏览器 ##FIXME
    copyClipboard: function(text) {
	if(window.clipboardData){
	    window.clipboardData.clearData();
	    window.clipboardData.setData('Text',text);
	    alert('已复制到剪切板！');
	}
    }
}

//导航条JS
var Navigation = {
    //通过设置Cookies来设置界面语言
    setLocale: function(locale) {
	$.cookie('locale', locale);
	location.reload();
    }
}

//表单JS
var Form = {
    //颜色选择器扩展
    colorPicker: function() {
	var f = $.farbtastic('#picker');
	var p = $('#picker').css('opacity', 0.25);
	var selected;
	$('.color_field')
	.each(function () {
	    f.linkTo(this);
	    $(this).css('opacity', 0.75);
	})
	.focus(function() {
	    if (selected) {
		$(selected).css('opacity', 0.75).removeClass('colorwell-selected');
	    }
	    f.linkTo(this);
	    p.css('opacity', 1);
	    $(selected = this).css('opacity', 1).addClass('colorwell-selected');
	});
    },
    //判断选择框是否选择，显示或隐藏一个块
    hideByCheckbox: function(checkbox, area) {
	$(checkbox).is(':checked') ? $(area).slideDown() : $(area).slideUp();
    },
    //显示一个块，隐藏一个块,第一个块显示，第二个块隐藏
    cycle: function(show_area, hide_area) {
	$(show_area).show();
	$(hide_area).hide();
    },
    //如果被选中，隐藏一个块，显示一个块
    cycByCheckbox: function(checkbox, show_area, hide_area) {
	if ($(checkbox).is(':checked')) {
	    Form.cycle(show_area, hide_area);
	} else {
	    Form.cycle(hide_area, show_area);
	}
    },
    //事件驱动：选中后显示一个块
    showWithCheckbox: function(checkbox, area) {
	$(checkbox).change(function() {
	    // $(this).is(':checked') ? $(area).slideDown() : $(area).slideUp();
	    Form.hideByCheckbox(checkbox, area);
	});
    },
    //事件驱动：选中后显示一个块，隐藏一个块
    cycOnChange: function(checkbox, type) {
	$(checkbox + '_ratio').change(function(){
	    Form.cycByCheckbox(this,type + '_ratio',type + '_time_stamp');
	})
	$(checkbox + '_time_stamp').change(function(){
	    Form.cycByCheckbox(this,type + '_time_stamp',type + '_ratio');
	})
	$(checkbox + '_none').change(function(){
	    if ($(this).is(':checked')) {
		$(type + '_ratio').hide();
		$(type + '_time_stamp').hide();
	    }
	})
    },
    //页面加载时，如果选中就显示一个块，隐藏一个块
    cycOnLoad: function(checkbox, type) {
	Form.cycByCheckbox(checkbox + '_ratio',type + '_ratio',type + '_time_stamp');
	Form.cycByCheckbox(checkbox + '_time_stamp',type + '_time_stamp',type + '_ratio');
	if ($(checkbox + '_none').is(':checked')) {
	    $(type + '_ratio').hide();
	    $(type + '_time_stamp').hide();
	}
    }
}

//site
var Site = {
    //首页demo图片显示切换
    showDemo: function(dom,demo) {
	$(dom).hover(
	    function () {
		$('#demo').show();
		$(demo).show();
	    },
	    function () {
		$('#demo').hide();
		$(demo).hide();
	    }
	    );
    }
}

//task模块JS
var Task = {
    //为选中的任务获取代码
    getCode: function(path,checkedboxs,area) {
	Common.showRoller(area); //显示等待图片
	var ids = ($("input[value][type=checkbox]").size() == checkedboxs.size() || Common.collectIds(checkedboxs) == '') ? '' : '/' + Common.collectIds(checkedboxs); //收集ID
	var full_path  = path + ids
	var html_code = '<b class="show_path">　网页版地址：<a href="' + full_path + '" target="_blank">' + full_path + '</a><br />　图片版地址：<a href="' + full_path + '.png" target="_blank">' + full_path + '.png</a></b>'
	html_code = html_code + '<h4 class="get_code">获取代码：</h4>'
	html_code = html_code + '<textarea class="get_code"><iframe name="wtools" src="' + full_path + '" width="100%" height="100%" style="float:left;" frameborder="0" scrolling="auto" marginheight="0" marginwidth="0"><iframe></textarea><button style="vertical-align: top" onclick="if(window.clipboardData){window.clipboardData.clearData();window.clipboardData.setData(\'Text\',$(\'textarea\').text());alert(\'已复制到剪切板！\');}"> 复制 </button>'
	$(area).html(html_code);
    },
    saveLog: function(task_id, log_id, percent_box, content_box, evaluation_box, log_table) {
	var content = content_box.size() == 1 ? content_box.val() : ''
	var percent = percent_box.size() == 1 ? percent_box.val() : 0
	var evaluation = evaluation_box.size() == 1 ? evaluation_box.val() : 0
	//alert(content);
	$.ajax({
	    type: 'post',
	    url: '/task_logs/save_log',
	    data: "task_id=" + task_id + "&log_id=" + log_id + "&percent=" + percent + "&content=" + content + "&evaluation=" + evaluation,
	    success: function(data) {
		$(log_table).replaceWith(data);
	    }
	})
    },
    //task#show 页面tab切换
    changeTab: function(current_div) {
	if (current_div != '#all') {
	    //先隐藏所有的
	    $('.task_show_div').each(function(){
		$(this).hide();
	    });
	    //再显示需要显示的
	    $(current_div).show();
	} else { //如果是显示全部
	    $('.task_show_div').each(function(){
		$(this).show();
	    });
	}
	//删除所有tab上的样式
	$(".tabs li").each(function(){
	    $(this).removeClass();
	})
	//为当前tab添加样式
	$(current_div + '_li').addClass("active");
    },
    //Plan创建表单中日志删除按钮动作
    delButtonHandle: function() {
	$('#log_flag').val(parseInt($('#log_flag').val()) - 1);
	$('#plan_time_num').val($('#log_flag').val());
	$('.plan_time_num_word').text($('#log_flag').val());
	$('#plan_logs_form div').last().remove();
    },
    //Plan创建表单中“增加X日志”按钮功能
    addLog: function(count) {
	var time_type = $("select option:selected").text();
	if (time_type) {
	    var current_count = parseInt($('#log_flag').val());
	    $('#log_flag').val(current_count + count);
	    $('#plan_time_num').val($('#log_flag').val());
	    $('.plan_time_num_word').text($('#log_flag').val());
	    for ( var i = 1; i <= count; i++ ) {
		$('#plan_logs_form').append('<div><span class="time_type_flag">第' + (current_count + i) + '<span class="plan_time_type_word">' + time_type + '</span>准备做' +
		    '：</span><input type="text" name="task_logs[][content]" id="task_log__name" /><input type="button" value="删除" onclick="Task.delButtonHandle();" /></div>')
	    }
	} else {
	    $('#plan_time_type').css({ "border-color": "red", "background-color": "#FECA40" });
	    alert('请先选择时间类型！');
	}
    }
}
//style模块JS
var Style = {
    //改变整个style表单
    changeSetting: function(area) {
	if($(area).text() != $("#style_name").val()) {
	    $('#style_name').val($(area).text());
	    $.ajax({
		type: "get",
		url: "/styles/get_setting",
		dataType: 'json',
		data: "name=" + $(area).text(),
		beforeSend: function() {
		    Common.showRoller("#get_setting_roller");//显示等待图片
		},
		success: function(data){
		    var area_arr = Style.areas();
		    var checkbox_arr = area_arr[0]; //控制显示
		    var input_arr = area_arr[1]; //控制颜色
		    var radio_arr = area_arr[2]; //控制进度条文字类型
		    $.each(data, function(k,v){
			var dom_str = '#style_' + k;
			if (v == true) { //checkbox选择框
			    $(dom_str).attr("checked","checked");
			    $.each(checkbox_arr, function(i,area){
				if (area[0] == dom_str) {
				    Form.hideByCheckbox(area[0],area[1]);
				}
			    })
			} else if (v == false) {//checkbox选择框
			    $(dom_str).removeAttr("checked");
			    $.each(checkbox_arr, function(i,area){
				if (area[0] == dom_str) {
				    Form.hideByCheckbox(area[0],area[1]);
				}
			    })
			} else if (v.toString().match(/^#\w{6}$/)) { //颜色输入框
			    $(dom_str).val(v);
			    $(dom_str).css("background-color",v)
			    $.each(input_arr, function(i,area){
				if (area[0] == dom_str) {
				    Style.setColor(area[0],area[1]);
				}
			    })
			} else {//radio单选按钮
			    $(dom_str + '_' + v).attr("checked","checked");
			    $.each(radio_arr, function(i,area){
				if (area[0] == dom_str) {
				    Form.cycOnLoad(area[0],area[1]);
				}
			    })
			}
		    });
		    Common.removeRoller("#get_setting_roller");//删除等待图片
		}
	    });
	}
	$("#style_list").slideUp();
    },
    //改变进度条颜色
    changeColor: function(input,area) {
	$(input).blur(function(){
	    $(area).css("background-color",$(this).val());
	    if(area != '.whold'){
		$(area).css("border-color",$(this).val());
	    }
	    $(area + '_percent').css("color",$(this).css("color"));
	})
    },
    //页面加载时设置颜色
    setColor: function(input,area) {
	$(area).css("background-color",$(input).val());
	if(area != '.whold'){
	    $(area).css("border-color",$(input).val());
	}
    },
    //样式定制页面表单项与预览区域关联数组
    areas: function() {
	return [
	[ //checkbox 选项
	['#style_name_display','#name'],//名称
	['#style_completed_display','.completed'],//已完成进度
	['#style_completed_display','#completed_word_type'],//已完成进度条上的文字类型
	['#style_should_completed_display','.should_completed'],//应完成进度
	['#style_should_completed_display','#should_completed_display'],//应完成进度条上的文字类型
	['#style_detail_display','.detail_buttom'],//日志信息
	['#style_detail_display','.detail_table'],//日志信息
	['#style_detail_display','#detail_display'],//日志信息子选项
	['#style_log_display','#log'],//日志信息
	['#style_log_display','.log'],//日志信息
	['#style_time_stamp_display','#time_stamp'],//时间标志
	['#style_time_stamp_display','.time_stamp'],//时间标志
	['#style_once_ratio_display','.once_percent'],//每次进度
	['#style_once_ratio_display','#once_percent'],//每次进度
	['#style_evaluation_display','#evaluation'],//每次评价
	['#style_evaluation_display','.evaluation'],//每次评价
	['#style_statistical_evaluation_display','#evaluation_statistical'],//自我评价统计
	['#style_aspire_word_display','#aspire_word']//立志语
	],
	[ //颜色输入框
	['#style_completed_bgcolor','.completed'],//已完成进度条
	['#style_should_completed_bgcolor','.should_completed'],//应完成进度条
	['#style_whole_bgcolor','.whole'],//整个进度条
	],
	[ //进度条文字类型: 百分比/时间量切换
	['#style_completed_word_type', '.completed'],//已完成百分比
	['#style_should_completed_word_type', '.should_completed'],//应完成百分比
	['#style_whole_word_type', '.whole']//整个百分比
	]
	];
    },
    //页面加载时应用设置
    deployOnLoad: function(){
	var area_arr = this.areas();
	var checkbox_arr = area_arr[0];
	var input_arr = area_arr[1];
	var radio_arr = area_arr[2];
	//显示设置
	$.each(checkbox_arr,function(i,area){
	    Form.hideByCheckbox(area[0],area[1]);
	});
	//进度条颜色设置
	$.each(input_arr,function(i,area){
	    Style.setColor(area[0],area[1]);
	});
	//进度条文字类型
	$.each(radio_arr,function(i,area){
	    Form.cycOnLoad(area[0],area[1]);
	});
    },
    //改变属性时，同步预览
    deployOnChange: function(){
	var area_arr = this.areas();
	var checkbox_arr = area_arr[0];
	var input_arr = area_arr[1];
	var radio_arr = area_arr[2];
	//设置显示、隐藏
	$.each(checkbox_arr,function(i,area){
	    Form.showWithCheckbox(area[0],area[1]);
	});
	//设置进度条颜色
	$.each(input_arr,function(i,area){
	    Style.changeColor(area[0],area[1]);
	});
	//设置进度条文字类型
	$.each(radio_arr,function(i,area){
	    Form.cycOnChange(area[0],area[1]);
	});
    }

}

//FeedBack模块JS
var FeedBack = {
    //投票Ajax
    vote: function(feedback_id,vote_type) {
	var dom_name = feedback_id + '_' + vote_type
	if ($.cookie('feedback_' + feedback_id) == 'true') {
	    alert('请不要重复投票!');
	} else {
	    var val = Number($('#' + dom_name).text())
	    $.ajax({
		type: "post",
		url: "/feedbacks/vote",
		data: "id=" + feedback_id + "&vote_type=" + vote_type,
		start: $('#' + dom_name).fadeOut("slow"),
		success: function(msg){
		    $('#' + dom_name).text(val + 1).fadeIn("slow");
		    $.cookie('feedback_' + feedback_id, 'true'); //添加cookies,防止重复投票
		}
	    });
	}
    }
}