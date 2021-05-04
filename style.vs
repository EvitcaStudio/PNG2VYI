#BEGIN WEBSTYLE

#wb_interface_canvas {
	overflow: hidden;
	border: 2px solid #f3f3f3;
}

#wb_interface_preview_canvas {
	overflow: hidden;
	border: 1px solid #f3f3f3;
}

#wb_interface_preview_canvas2 {
	overflow: hidden;
	border: 1px solid #f3f3f3;
}

.preview {
	font-size: 15px;
	font-family: Arial;
}

::-webkit-scrollbar {
	width: 8px;
	height: 8px;
}

::-webkit-scrollbar-track {
	border-radius: 10px;
	background: rgba(0, 0, 0, 0.1);
}

::-webkit-scrollbar-thumb {
	border-radius: 10px;
	background: rgba(0, 0, 0, 0.2);
}
	
::-webkit-scrollbar-thumb:hover {
	background: rgba(0, 0, 0, 0.4);
}
	
::-webkit-scrollbar-thumb:active {
	background: rgba(0, 0, 0, 0.9);
}

label {
	display: inline-block;
	width: 120px;
	height 50px;
	overflow: visible;
}

.fake-button {
	display:inline-block;
	border:0.1em solid #000;
	border-radius:0.12em;
	box-sizing: border-box;
	text-decoration:none;
	font-family:'Roboto',sans-serif;
	font-color: #f3f3f3;
	font-weight:300;
	color: #f3f3f3;
	background-color: rgb(51, 51, 51);
	text-align:center;
	transition: all 0.2s;
}

.fake-button:hover {
	color:#a9a9a9;
	background-color:#1c1e1f;
}

/*
.container {
	position: absolute;
	top:0;
	bottom: 0;
	left: 0;
	right: 0;
	margin: auto;
}
*/

.container {
   position: absolute;
   top: 50%;
   left: 50%;
   -moz-transform: translateX(-50%) translateY(-50%);
   -webkit-transform: translateX(-50%) translateY(-50%);
   transform: translateX(-50%) translateY(-50%);
}



#END WEBSTYLE