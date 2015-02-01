<%--@author AmilaS--%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
<title>Word Analyzer</title>

<link href="${pageContext.request.contextPath}/resources/css/trs_console.css" rel="stylesheet" type="text/css"/>
<link href="${pageContext.request.contextPath}/resources/css/monitor_table.css" rel="stylesheet" type="text/css"/>
<link href="${pageContext.request.contextPath}/resources/css/jquery-ui-1.8.4.custom.css" rel="stylesheet"
      type="text/css" media="all"/>

<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery.dataTables.min.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/resources/js/jquery-ui.min.js"></script>

<script src="${pageContext.request.contextPath}/resources/js/jquery.jpanelmenu.min.js" type="text/javascript"></script>

<script type="text/javascript">
    $(document).ready(function () {
        var jPM = $.jPanelMenu({
            menu: 'header.main nav',
            animated: true
        });
        jPM.on();
        $("#loadingImage").hide();
        $("#subtitle").html("Messages of Session")
    });

</script>

<script type="text/javascript">

    var reqUrl = "masteredWords";

    $(document).ready(function () {
        var $lmTable = $("#information").dataTable({
            "sPaginationType": "full_numbers",
            "sScrollX": "1000px",
            "sScrollY": calcDataTableHeight(),
            "sSearch": "Search all:",
            "iDisplayLength": 100,
            "aaSorting": [
                [0, 'desc']
            ],
            //"bJQueryUI": true
            "aaData": [],
            "aoColumns": [
//                { "mDataProp": "id", sDefaultContent: "n/a"},
                { "mDataProp": "rank", sDefaultContent: "n/a"},
                { "mDataProp": "word", sDefaultContent: "n/a"},
                { "mDataProp": "partsOfSpeech", sDefaultContent: "n/a"},
                { "mDataProp": "remarks", sDefaultContent: "n/a"}
            ]
        });

        var $searchBar = $("tfoot input");

        $searchBar.keyup(function () {
            /* Filter on the column (the index) of this element */
            $lmTable.fnFilter(this.value, $("tfoot input").index(this));
        });


        var asInitVals = [];
        /*
         * Support functions to provide a little bit of 'user friendlyness' to the textboxes in
         * the footer
         */
        $searchBar.each(function (i) {
            asInitVals[i] = this.value;
        });

        $searchBar.focus(function () {
            if (this.className == "search_init") {
                this.className = "";
                this.value = "";
            }
        });

        $searchBar.blur(function (i) {
            if (this.value == "") {
                this.className = "search_init";
                this.value = asInitVals[$("tfoot input").index(this)];
            }
        });


//        if close button is clicked
        $('.window .close').click(function (e) {
            //Cancel the link behavior
            e.preventDefault();
            $('#mask').hide();
            $('.window').hide();
        });

//        if mask is clicked
        $('#mask').click(function () {
            $(this).hide();
            $('.window').hide();
        });

        $(window).resize(function () {
            var box = $('#boxes .window');
            //Get the screen height and width
            var maskHeight = $(document).height();
            var maskWidth = $(window).width();
            //Set height and width to mask to fill up the whole screen
            $('#mask').css({'width': maskWidth, 'height': maskHeight});
            //Get the window height and width
            var winH = $(window).height();
            var winW = $(window).width();
            //Set the popup window to center
            box.css('top', winH / 2 - box.height() / 2);
            box.css('left', winW / 2 - box.width() / 2);
        });

        refreshMessages(reqUrl);
//        refreshTime();

    });

    var calcDataTableHeight = function () {
        var h = Math.floor($(window).height() * 55 / 100);
        return h + 'px';
    };
    $(window).resize(function () {
        var oTable = $("#information").dataTable();
        $('div.dataTables_scrollBody').css('height', calcDataTableHeight());
        oTable.fnAdjustColumnSizing();
    });

    function refreshTime() {
        $.get("serverTime", function (response) {
            $("#server-time-text").html(response[0] + "<br/>" + response[1]);
        });
        setTimeout(refreshTime, 60000);
    }

    function refreshMessages(url) {
        $('#information').hide();
        $('#loadingImage').show();
        $.get(url, function (responseJson) {
            $('#information').show();
            $('#loadingImage').hide();
            refreshTable(responseJson)
        });
    }

    var $lmTable;

    function refreshTable(responseJson) {
        $lmTable = $("#information").dataTable();
        $lmTable.fnClearTable(this);
        $.each(responseJson, function (index, message) {
            $lmTable.fnAddData(message, false);
        });
        $lmTable.fnDraw(this);
    }

    $(document).on('click', '#information tbody tr', function () {
        var aData = $lmTable.fnGetData(this);
        var msgWindow = $('#dialog');
        $('#requestText').html("Loading word...");
        $('#wordLabel').html(aData.word);
        wordLabel
        $.get("word", {word: aData.word}, function (res) {
            $('#requestText').html(res);

            var box = $('#boxes .window');
            //Get the window height and width
            var winH = $(window).height();
            var winW = $(window).width();
            //Set the popup window to center
            $(box).css('top', winH / 2 - $(msgWindow).height() / 2);
            $(box).css('left', winW / 2 - $(msgWindow).width() / 2);
        });

        //Get the screen height and width
        var maskHeight = $(document).height();
        var maskWidth = $(window).width();
        //Set height and width to mask to fill up the whole screen
        var mask = $('#mask').css({'width': maskWidth, 'height': maskHeight});
        //transition effect
        mask.fadeIn(300);
        mask.fadeTo("slow", 0.8);

        //transition effect
        $(msgWindow).fadeIn(600);

    });

</script>

<style type="text/css">
    #mask {
        position: absolute;
        left: 0;
        top: 0;
        z-index: 9000;
        background-color: #000;
        display: none;
    }

    #boxes .window {
        position: fixed;
        left: 0;
        top: 0;
        max-width: 90%;
        max-height: 90%;
        display: none;
        z-index: 9999;
        padding: 20px;
    }

    #boxes #dialog {
        /*background:url(images/notice.png) no-repeat 0 0 transparent;*/
        /*padding:50px 0 20px 25px;*/
        padding: 10px;
        background-color: #ffffff;
        /*overflow: auto;*/
    }

    pre {
        outline: 1px solid #ccc;
        padding: 5px;
        margin: 5px;
    }

    .string {
        color: green;
    }

    .number {
        color: darkorange;
    }

    .boolean {
        color: blue;
    }

    .null {
        color: magenta;
    }

    .key {
        color: black;
    }

</style>

</head>
<body id="messages_body">

<%@include file="menu.jsp" %>

<div class="content" id="container" style="width: 98%; margin: auto">

    <br/>
    <br/>

    <div id="message_info">

        <div id="loadingImage" align="center">
            <img src="${pageContext.request.contextPath}/resources/images/ajax-loader.gif" alt="Loading..."/>
        </div>

        <table id="information" class="display">
            <thead>
            <tr>
                <th>RANK</th>
                <th>WORD</th>
                <th>PART OF SPEECH</th>
                <th>REMARKS</th>
            </tr>
            </thead>
            <tbody id="infoBody">
            </tbody>
            <tfoot>
            <tr class="search_bar">
                <th><input type="text" name="search_rank" value="Search rank" class="search_init"/></th>
                <th><input type="text" name="search_word" value="Search word" class="search_init"/></th>
                <th><input type="text" name="search_pos" value="Search pos" class="search_init"/></th>
                <th><input type="text" name="search_rem" value="Search rem" class="search_init"/></th>
            </tr>
            </tfoot>
        </table>
    </div>


    <div id="boxes">
        <div id="dialog" class="window">
            <table>
                <tr>
                    <td style="vertical-align:top;">
                        Word: <label id="wordLabel"></label>
                        <br/>
                        <pre><div id="requestText" style="height:500px;width:800px;overflow:auto"></div></pre>
                    </td>
                </tr>
            </table>
            <input type="button" value="Close it" class="close"/>
        </div>
        <!-- Mask to cover the whole screen -->
        <div id="mask"></div>
    </div>


</div>

</body>
</html>