<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

    <!DOCTYPE html>
<html>
<head lang="en">

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="initial-scale=1.0, user-scalable=no, width=device-width">
    <title>车辆管理平台</title>

    <!--<script src="http://siteapp.baidu.com/static/webappservice/uaredirect.js" type="text/javascript"></script>-->
    <!--<script type="text/javascript">uaredirect("http://10.103.91.168:8080/index.html");</script>-->

    <script src="http://code.jquery.com/jquery-2.1.1.min.js"></script>
    <script src="http://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.js"></script>

    <!--<link type="text/css" rel="stylesheet" href="jquery-ui.min.css">-->
    <link rel="stylesheet" href="http://code.jquery.com/mobile/1.4.5/jquery.mobile-1.4.5.min.css"/>
    <link rel="stylesheet" href="http://cache.amap.com/lbs/static/main.css?v=1.0?v=1.0"/>

    <script type="text/javascript"
            src="http://webapi.amap.com/maps?v=1.3&key=a51711ba75b2f6f205da4e278c7ea51c&plugin=AMap.ToolBar"></script>
    <script type="text/javascript" src="http://cache.amap.com/lbs/static/addToolbar.js"></script>

    <script>
        //两个全局变量
        var queryType = -1;//用于保存目前数据的类型
        var json_data = null;//用于保存从服务器返回的数据

        $(document).ready(function () {
            $("#carId").attr("disabled", true);
            $("#select_ShowWhat option[value='Trail']").remove();


            $("#bt_search").click(function dataQuery() {
                //第一类请求。全部车辆+位置｛请求命令包括：queryType=1｝此时服务器返回，全部车辆，最新位置信息。
                if ($('#select-range option:selected').val() == "all") {

                    alert("第一类命令");
                    map.clearMap();
                    $.ajax({
                        type: "POST",
                        url: "MobileServlet",//服务点地址
                        dataType: "json",
                        data: {
                            queryType: "1"//请求类型
                        }
                        ,
                        success: function (data, textStatus) {
                            queryType = "1";//将命令类型保存为全局变量
                            json_data = data;//将返回的数据保存在全局变量
                            dataProsess(queryType, json_data);//处理数据方法
                        }
                        ,
                        error: function (data, textStatus) {
                            console.log(data);
                            console.log(textStatus);
                        }
                    })
                    ;
                } else if ($('#select-range option:selected').val() == "single" & $('#select_ShowWhat option:selected').val() != "Trail") {
                    //第二类请求。2.指定车辆+车牌号+位置｛请求命令包括：queryType=2；车牌号=XXXXXX；｝（此时服务器返回制定车牌号的车辆的最新位置信息，仅一条数据）
                    alert("第二类命令");
                    if (!$('#carId').val()) {//判断车架号是否为空
                        alert("请输入车架号！");
                    } else {
                        alert($('#carId').val());
                        $.ajax({
                            type: "POST",
                            url: "MobileServlet",//服务点地址
                            dataType: "json",
                            data: {
                                queryType: "2",//请求类型
                                carid: $('#carId').val()//车辆ID
                            }
                            ,
                            success: function (data, textStatus) {
                                queryType = "2";//将命令类型保存为全局变量
                                json_data = data;//将返回的数据保存在全局变量
                                dataProsess(queryType, json_data);//处理数据方法
                            }
                            ,
                            error: function (data, textStatus) {
                                console.log(data);
                                console.log(textStatus);
                            }
                        })
                        ;
                    }


                } else if ($('#select-range option:selected').val() == "single" & $('#select_ShowWhat option:selected').val() == "Trail") {
                    //第三类请求。3.指定车辆+车牌号+轨迹+起始时间+终止时间｛请求命令包括：queryType=3；车牌号=XXXXXX；起始时间=SSSSSS；终止时间=EEEEEE｝
                    alert("第三类命令");
                    if (!$('#carId').val()) {//判断车架号是否为空
                        alert("请输入车架号！");
                    } else if (!$("#start_time").val() | !$("#start_time").val()) {//判断时间是否输入准确
                        alert("请输入完整的时间段");
                    } else if (!timeTF()){
                        alert("时间输入有误，开始时间应小于结束时间");
                    }else{//当输入均为正确时
                        alert("输入正确"+$('#carId').val());//
                        $.ajax({
                            type: "POST",
                            url: "MobileServlet",//服务点地址
                            dataType: "json",
                            data: {
                                queryType: "3",//请求类型
                                carid: $('#carId').val(), //车辆ID
                                start_time:$("#start_time").val(),//开始时间
                                end_time:$("#end_time").val()//终止时间
                            }
                            ,
                            success: function (data, textStatus) {
                                queryType = "3";//将命令类型保存为全局变量
                                json_data = data;//将返回的数据保存在全局变量
                                dataProsess(queryType, json_data);//处理数据方法
                            }
                            ,
                            error: function (data, textStatus) {
                                console.log(data);
                                console.log(textStatus);
                            }
                        })
                        ;
                    }

                } else {
                    alert("逻辑出错");

                }


                /* //点标记
                 var p1 = new AMap.LngLat(116.43215, 39.922303);
                 var p2 = new AMap.LngLat(116.356619, 39.917432);
                 var p3 = new AMap.LngLat(116.379536, 39.960602);
                 var p4 = new AMap.LngLat(116.521671, 39.932308);

                 var data = new Array();
                 data[0] = p1;
                 data[1] = p2;
                 data[2] = p3;
                 data[3] = p4;
                 showLocation(data);

                 routePlan(data);*/
                /*
                 //根据起终点坐标规划驾车路线
                 var p1 = new AMap.LngLat(116.43215, 39.922303);
                 var p2 = new AMap.LngLat(116.356619, 39.917432);
                 var p3 = new AMap.LngLat(116.379536, 39.960602);
                 var p4 = new AMap.LngLat(116.521671, 39.932308);

                 var data = new Array();
                 data[0] = p1;
                 data[1] = p2;
                 data[2] = p3;
                 data[3] = p4;
                 routePlan(data);
                 */
            });
            function dataProsess(type, data) {
                //json_data = data;
//                if (json_data == null || json_data == '') {
//                    alert("此时段没有该车辆的路径轨迹");
//                } else {
//                    allVeh(json_data);
//                    routePlan(json_data);
//                }
                switch (type) {
                    case "1":
                        A();//用于处理第一类命令所返回的数据；
                        break;
                    case "2":
                        B();//用于处理第二类命令所返回的数据；
                        break;
                    case "3":
                        C();//用于处理第三类命令所返回的数据；
                        break;
                }
            }

            $("#bt_carInfo").click(function () {
//                map.clearMap();//清空地图
//                alert($("#time").val());
                ////
//                var time = new Date($("#start_time").val()).getTime();
//                var time2 = new Date($("#end_time").val()).getTime();
//                alert($("#start_time").val());


//                alert("start:" + s_time + "|||||end:" + e_time);
//                if(time>time2){
//                    alert("kaishi dayu jieshu");
//                }
                if(timeTF()){
                    alert("时间正确");
                }else if(!timeTF()){
                    alert("时间错误");
                }

                ////
                /* console.log($("#time").val());
                 var time = $("#time").val();
                 var time1;
                 time1 = time.split(":");
                 console.log("hour:" + time1[0] + "\nsecond:" + time1[1]);*/
            });
           function  timeTF() {
                var s_time = $("#start_time").val();
                var s_time = parseInt(s_time.split(":")[0] * 60) + parseInt(s_time.split(":")[1]);
                var e_time = $("#end_time").val();
                var e_time = parseInt(e_time.split(":")[0] * 60) + parseInt(e_time.split(":")[1]);
                if (s_time >= e_time) {
                    return false;
                }
                else if (s_time < e_time) {
                    return true;
                }
            }

            $("#select-range").change(function () {
                if ($(this).val() == "single") {
//                    alert("单车");
//                    $("#carId").removeAttr("disabled");
                    $("#carId").attr("disabled", false);
                    $("#trail").attr("disabled", false);
                    $("#select_ShowWhat").append("<option value='Trail'>轨迹</option>");//添加option
//                    $("#select_showWhat").val("Trail").attr("readonly",false);
                } else {
                    $("#carId").attr("disabled", true);
                    $("#trail").attr("disabled", true);
                    $("#select_ShowWhat option[value='Trail']").remove();
                    $("#select_ShowWhat option[value='GPS']").attr("selected", "selected");
//                    $("#select_ShowWhat").val("CellId").prop("selected", true);
//                    $("#select_ShowWhat").reset();
//                    $("#select_ShowWhat").get(0).value = "2";
//                    var text1="CellId";
//                    $("#select_ShowWhat option[text = text1]").attr("selected", "selected");
//                    $("#select_showWhat").val("Trail").attr("readonly",true);
                }

            });

        });


    </script>
    <script>

        function init() {
            var mapHeight = $(window).height() - $("#div2").offset().top - $("#div2").height();
            $("#mapContainer").css({
                "position": "absolute",
                "top": $("#div1").height() + $("#div2").height() + 3,
                "height": mapHeight - 3
            });

            map = new AMap.Map("mapContainer"); //新建一个地图
            //给地图添加控件
            AMap.plugin(['AMap.ToolBar', 'AMap.MapType', 'AMap.Geolocation'],
                    function () {
                        map.addControl(new AMap.ToolBar());

//                        map.addControl(new AMap.Scale());

                        map.addControl(new AMap.MapType({
                            defaultType: 0 //使用2D地图
                        }));

                        map.addControl(new AMap.Geolocation());

                    });
            //设置城市
            AMap.event.addDomListener(document.getElementById('query'), 'click', function () {
                var cityName = document.getElementById('cityName').value;
                if (!cityName) {
                    cityName = '北京市';
                }
                map.setCity(cityName);
            });


            map.addControl(new AMap.ToolBar());
            if (AMap.UA.mobile) {
                document.getElementById('bitmap').style.display = 'none';
                bt.style.fontSize = '16px';
            } else {
                bt.style.marginRight = '10px';
            }
        }

        /**
         *
         * 显示点
         */

        function showLocation(data) {
            //添加点标记，并使用自己的icon
            $.each(data, function (index) {
                new AMap.Marker({
                    map: map,
//                position: [116.405467, 39.907761],
                    position: data[index],
                    icon: new AMap.Icon({
                        size: new AMap.Size(40, 50),  //图标大小
                        image: "http://webapi.amap.com/theme/v1.3/images/newpc/way_btn2.png",
                        imageOffset: new AMap.Pixel(0, -60)
                    })
                });
            });


        }
        /**
         * 点集合按路径规划方式连接方法。传入的data参数为坐标数组
         * @param data
         */
        function routePlan(data) {
//            alert(data);

            //驾车导航模块
            AMap.plugin(["AMap.Driving"], function () {
                drivingOption = {
                    policy: AMap.DrivingPolicy.LEAST_TIME,
                    map: map,
                    hideMarkers: true,
                    showTraffic: false
                };

                $.each(data, function (index) {
                    //index为索引
                    //name为值
                    //如果使用函数的上下文this则相当于第二个参数
                    var driving = new AMap.Driving(drivingOption); //构造驾车导航类
                    driving.search(data[index], data[index + 1], function (status, result) {
                        button.onclick = function () {
                            driving.searchOnAMAP({
                                origin: result.origin,
                                destination: result.destination
                            });
                        }
                    });

                });

            });
        }


    </script>
</head>


<body onload="init()">

<div data-role="page" id="pageone">

    <div data-role="header">
        <!--<h1>标题</h1>-->
    </div>

    <div data-role="content" style="margin: 0px;padding: 0px">

        <!--<div id="formcontener2" style="margin: 0px;padding: 0px; height: 40%;">-->

        <div id="div1" class="ui-grid-solo" style="height:20%">

            <div style="float:left;width:38%;margin-right: 2%;margin-left: 2%;">
                <select name="searchRange" id="select-range">
                    <option value="all">全部车辆</option>
                    <option value="single">指定车辆</option>
                </select>
            </div>


            <div style="float:left;width:38%;margin-right: 2%;">
                <label class="ui-hidden-accessible" for="carId">Text Input:</label>
                <input name="carId" id="carId" type="text" placeholder="请输入车架号：" value=""
                       data-clear-btn="true">
            </div>


            <div style="float:left;width:16%;margin-right: 2%;">
                <!--<a href="#" class="ui-button" id="btn1">查询</a>-->
                <button id="bt_search" type="button" data-theme="c">查询</button>
            </div>

        </div>

        <div class="ui-grid-solo" id="div2" style="height:20%">

            <div style="float:left;width:35%;margin-right: 2%;margin-left: 2%;">
                <select name="showWhat" id="select_ShowWhat">
                    <option value="GPS">GPS</option>
                    <option value="CellId">CellId</option>
                    <option id="trail" value="Trail">轨迹</option>
                </select>
            </div>


            <div style="float:left;width:16%;margin-right: 2%;">
                <input name="time" id="start_time" type="time" value="">
            </div>
            <div style="float:left;width:16%;margin-right: 2%;">
                <input name="time" id="end_time" type="time" value="">
            </div>

            <div style="float:left;width:23%;margin-right: 2%;">
                <!--<a href="#" class="ui-button" id="btn1">查询</a>-->
                <button id="bt_carInfo" type="button">车辆信息</button>
            </div>

        </div>
        <!--style="width:100%;height:60%;background: red"class="ui-grid-solo"-->


        <div class="ui-grid-solo" id="mapContainer"></div>
        <div class="button-group" style="margin-right: 10%">
            <input id="cityName" class="inputtext" placeholder="请输入城市的名称" type="text"/>
            <input id="query" class="button" value="到指定的城市" type="button"/>
        </div>

    </div>


    <div data-role="footer">

    </div>

</div>


</body>
</html>