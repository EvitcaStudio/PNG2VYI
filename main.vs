#DEFINE DEFAULT_TYPE 'Tile'

World
	gameWidth = 1280
	gameHeight = 720

var vyi = {
	'v': 1,
	'i': []
}

var vys = ''
var canvas
var preview_canvas
var preview_canvas2
var fileName
var type
var rideAlong
var firstTypeAdded
var client
var defaultType = DEFAULT_TYPE // for referencing in js

var name
var width
var height
var frameDelay = 100
var reset = false

const newLine = '\n'
const tab = '\t'

Interface
	onMouseDown(client, x, y, button)
		if (this.draggable && button === 1)
			client.dragging = { 'element': this, 'xOff': x, 'yOff': y }
			
	png2vyi
		interfaceType = 'WebBox'
		mouseOpacity = 0
		var draggable = true
		var defaultText

		Canvas
			mouseOpacity = 2
			onNew()
				this.defaultPos = { 'x': this.xPos, 'y': this.yPos }
				this.text = '<div class="container"><canvas id="canvas">Your browser doesn\'t support canvas tag</canvas></div>'

			onMouseClick(client, x, y, button)
				if (button === 3)
					this.setPos(this.defaultPos['x'], this.defaultPos['y'])

		Text_Label
			width = 100
			height = 75
			layer = 101
			textStyle = {'fill': '#fff'}
			onNew()
				this.text = '<div class="preview">Current</div>'

		Text_Label2
			width = 100
			height = 75
			layer = 101
			textStyle = {'fill': '#fff'}
			onNew()
				this.text = '<div class="preview">Previous</div>'


		Preview_Canvas
			layer = 100
			onNew()
				this.text = '<div class="container"><canvas id="preview_canvas">Your browser doesn\'t support canvas tag</canvas></div>'
				this.defaultText = this.text 

		Preview_Canvas2
			layer = 100
			onNew()
				this.text = '<div class="container"><canvas id="preview_canvas2">Your browser doesn\'t support canvas tag</canvas></div>'
				this.defaultText = this.text 

		Upload
			width = 120
			height = 18
			onNew()
				this.text = '
							<label class="fake-button">
								<input type="file" onchange="handleFileSelect(event)" style="display: none; id="upload" accept="image/*">
								<div>Import</div>
							</label>
							'
		Export
			width = 120
			height = 18
			onNew()
				this.text = '
							<label class="fake-button">
								<a id="export">Export</a>
							</label>
							'

		Export_Vys
			width = 120
			height = 18
			onNew()
				this.text = '
							<label class="fake-button">
								<a id="export_vys">Export Vs</a>
							</label>
							'

		Img
			interfaceType = 'WebBox'
			width = 1
			height = 1

			onShow()
				this.text = '
							<div>
								<img id="image" onload="drawImgToCanvas()" draggable="false">
							</div>
							'

Client
	screenView = { 'scaleNearest': true, 'disableImageSmoothing': false, 'scaleTo': 'ratio' }
	screenBackground = '#23272A'
	hideFPS = true

	onMouseMove(diob, x, y)
		if (this.dragging)
			this.dragging['element'].setPos(x - this.dragging['xOff'], y - this.dragging['yOff'])

	onMouseUp(diob, x, y, button)
		if (this.dragging && button === 1)
			this.dragging = null

	onConnect()
		this.showInterface('interface')
		client = this
		canvas = this.getInterfaceElement('interface', 'canvas')
		preview_canvas = this.getInterfaceElement('interface', 'preview_canvas')
		preview_canvas2 = this.getInterfaceElement('interface', 'preview_canvas2')

		rideAlong = this.confirm('Would you like to witness each sprite cut and determine if its a frame or icon state, as well as define its type? \n\n OK: Yes\n\n Cancel: No (all sprites will be its own icon and all diobs will be of ' + DEFAULT_TYPE + ' baseType)')
		width = this.prompt('Width of sprites in tileset?', 24)
		height = this.prompt('Height of sprites in tileset?', 24)

		width = Util.toNumber(width)
		height = Util.toNumber(height)

		if (!width || !height)
			return World.kickClient(this, 'A number was not inputted for the width or height of the sprites')

		preview_canvas.width = width * 2
		preview_canvas.height = height * 2

		preview_canvas2.width = width * 2
		preview_canvas2.height = height * 2

		JS.makeWorker({'w': width, 'h': height})

		if (!Util.isNumber(width) || !Util.isNumber(height))
			return World.kickClient(this, 'A number was not inputted for the width or height of the sprites')

		if (!rideAlong)
			name = this.prompt('Name to be used for all diobs with a variable counter appended to the end: ', 'NamelessDiob')
			if (!name) name = 'NamelessDiob'

function makeVyi()
	var canvas = JS.document.getElementById('canvas')
	var context = canvas.getContext('2d')
	var img = JS.document.getElementById('image')
	var count = 0
	var iconVector = {'x': 0, 'y': 0}
	var stateCount = 0
	var vyiIconIndex
	var wasState
	var wasFrame
	var previousDraw
	var tiles = Math.round((img.width / width) * (img.height / height)) + 100 //find a more solid fix then this, the last few tiles of some images are cut off without this
	var x = 0
	var y = 0

	for (var i=0; i < tiles; i++)
		if (x > Math.round((img.width / width)))
			x = 0
			y++
		var blank
		var data = context.getImageData(x * width, y * width, width, height).data

		for (var v = 0; v < data.length; v += 4)
			if (data[v + 3] !== 0)
				blank = false
				break
			else
				blank = true
		
		if (!blank)
			if (rideAlong)
				if (previousDraw && wasState && !wasFrame || previousDraw && !wasState && !wasFrame) // if and it was a icon state update the preview
					JS.WORKER2.postMessage({ 'msg': 'drawPrevious', 'previous': previousDraw })
				JS.WORKER.postMessage({ 'msg': 'drawPreview', 'x': x * width, 'y': y * height })
				previousDraw = { 'x': x * width, 'y': y * height }

				if (wasState)
					var isStateFrame = client.confirm('Is this a frame of the last ICON STATE? \nOk: Yes\nCancel: No')
					if (isStateFrame)
						// send the old vyiIconIndex so it doesnt change
						JS.WORKER.postMessage({ 'msg': 'getBlob', 'state_count': stateCount-1, 'state_frame': true, 'array': [null], 'count': vyiIconIndex })
						x++
						wasState = true
						wasFrame = true
						stateFrame++
						continue
					else
						wasState = null
						wasFrame = null

				if (!count) // first image
					name = client.prompt('Name of icon?', 'NamelessDiob' + count)
					type = client.prompt('This diob\'s baseType is? : ', DEFAULT_TYPE)
					if (!name) name = 'NamelessDiob' + count
					if (!type) type = DEFAULT_TYPE
					JS.WORKER.postMessage({ 'msg': 'getBlob', 'array': [name.toLowerCase(), width, height, frameDelay, null, [], []] })
					if (type === DEFAULT_TYPE)
						vys += makeTypeString(type, name, fileName)
					else
						vys += makeTypeString(type, name, fileName)

					count++
					x++
					continue

				else // every image after
					// show last image beside current image
					if (stateFrame)
						JS.WORKER2.postMessage({ 'msg': 'drawPrevious', 'previous': { 'x': iconVector['x'], 'y': iconVector['y'] } })
					var isFrame = client.confirm('Is this a frame of the last ICON? \nOk: Yes\nCancel: No')
					if (isFrame)
						if (!vyiIconIndex)
							vyiIconIndex = count-1 // last icon
						wasFrame = true
						wasState = null
						JS.WORKER.postMessage({ 'msg': 'getBlob', 'frame': true, 'array': [null], 'count': vyiIconIndex })
						x++
						continue

					var isState = client.confirm('Is this a iconState of the last ICON?\nOk: Yes\nCancel: No')
					if (isState)
						if (!vyiIconIndex)
							vyiIconIndex = count-1 // last icon
						var stateName = client.prompt('Name to be used for this ICON STATE: ', 'state' + stateCount)
						if (!stateName)
							stateName = 'state' + stateCount
						JS.WORKER.postMessage({ 'msg': 'getBlob', 'state': true, 'array': [stateName.toLowerCase(), null, frameDelay, []], 'count': vyiIconIndex })
						x++
						stateCount++
						wasFrame = null
						wasState = true
						stateFrame = 0
						continue

				name = client.prompt('Name of Type? *will also be the iconName*', 'NamelessDiob' + count)
				type = client.prompt('This diob\'s baseType is? : ', DEFAULT_TYPE)
				if (!name) name = 'NamelessDiob' + count
				if (!type) type = DEFAULT_TYPE
				JS.WORKER.postMessage({ 'msg': 'getBlob', 'array': [name.toLowerCase(), width, height, frameDelay, null, [], []] })
				if (type === DEFAULT_TYPE)
					vys += makeTypeString(type, name, fileName)
				else
					vys += makeTypeString(type, name, fileName)
				vyiIconIndex = null
				wasState = null
				wasFrame = null
				stateCount = 0
				iconVector = {'x': x * width, 'y': y * height}
				
			else
				JS.WORKER.postMessage({ 'msg': 'drawPreview', 'x': x * width, 'y': y * height })
				JS.WORKER.postMessage({ 'msg': 'getBlob', 'array': [(name+count).toLowerCase(), width, height, frameDelay, null, [], []] })
				if (firstTypeAdded)
					vys += makeTypeString(null, name, fileName, { 'firstType': false, 'count': count })
				else
					vys += makeTypeString(null, name, fileName, { 'firstType': true, 'count': count })
					firstTypeAdded = true

			count++
		x++

	if (!rideAlong)
		JS.document.getElementById('export').setAttribute('href', 'data:text/plain;charset=utf-8,' + Util.encodeURIComponent(Util.toString(vyi)))
		JS.document.getElementById('export').setAttribute('download', fileName + '.vyi')

		JS.document.getElementById('export_vys').setAttribute('href', 'data:text/plain;charset=utf-8,' + Util.encodeURIComponent(vys))
		JS.document.getElementById('export_vys').setAttribute('download', fileName + '_type_defines.vs')

function makeTypeString(type, name, fileName, info)
	var nT = newLine + tab
	if (info)
		var string = ''
		if (info['firstType'])
			string += DEFAULT_TYPE + nT + (name + info['count']) + nT + tab + 'atlasName = \'' + fileName + '\'' + nT + tab + 'iconName = \'' + (name + info['count']).toLowerCase() + '\'' + newLine + '\r'
		else
			string += tab + (name + info['count']) + nT + tab + 'atlasName = \'' + fileName + '\'' + nT + tab + 'iconName = \'' + (name + info['count']).toLowerCase() + '\'' + newLine + '\r'
		return string

	var tempCount = 1

	for (var i = 0; i < type.length; i++)
		if (type[i] === '/')
			type = type.replace('/', nT)
			tempCount++
			nT = newLine + tab.repeat(tempCount)

	type += (newLine + tab.repeat(tempCount)) + name + (newLine + tab.repeat(tempCount + 1)) + 'atlasName = \'' + fileName + '\'' + (newLine + tab.repeat(tempCount + 1)) + 'iconName = \'' + name.toLowerCase() + '\'' + newLine + '\r'
	return type

#BEGIN JAVASCRIPT
var WORKER
var WORKER2

function prepareExport() {
	VS.global.reset = true
	document.getElementById('export').setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(JSON.stringify(VS.global.vyi)));
	document.getElementById('export').setAttribute('download', VS.global.fileName + '.vyi');

	document.getElementById('export_vys').setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(VS.global.vys));
	document.getElementById('export_vys').setAttribute('download', VS.global.fileName + '_type_defines.vs');
}

function blobToDataURL(blob, array, count, type, stateCount) {
	var reader = new FileReader();
	reader.onload = function() {
		array[array.indexOf(null)] = reader.result.replace('data:image/png;base64,', '');
		if (type) {
			switch (type) {
				case 'state':
					VS.global.vyi['i'][count][6].push(array);
					break;

				case 'frame':
					VS.global.vyi['i'][count][5].push(array);
					break;

				case 'state_frame':
					VS.global.vyi['i'][count][6][stateCount][3].push(array);
					break;
			}
			prepareExport();

		} else {
			VS.global.vyi['i'].push(array);
			prepareExport();
		}
   }
   reader.readAsDataURL(blob);
}

function makeWorker(json) {
	var canvas = document.getElementById('preview_canvas');
	var offscreen = canvas.transferControlToOffscreen();

	var canvas2 = document.getElementById('preview_canvas2');
	var offscreen2 = canvas2.transferControlToOffscreen();

	WORKER = new Worker(VS.Resource.getResourcePath('file', 'worker.js'));
	WORKER.postMessage({ 'canvas': offscreen, 'msg': 'setup', 'json': json }, [offscreen]);

	WORKER.onmessage = function(e) {
		switch (e.data.msg) {
			case 'blob':
				if (e.data.type) {
					if (typeof e.data.state_count === 'number') {
						blobToDataURL(e.data.blob, e.data.array, e.data.count, e.data.type, e.data.state_count);
					} else {
						blobToDataURL(e.data.blob, e.data.array, e.data.count, e.data.type);
					}
				} else {
					blobToDataURL(e.data.blob, e.data.array);
				}
				break;
		}

	}

	WORKER2 = new Worker(VS.Resource.getResourcePath('file', 'worker2.js'));
	WORKER2.postMessage({ 'canvas': offscreen2, 'msg': 'setup2', 'json': json }, [offscreen2]);
}

function handleFileSelect(event) {
	var selectedFile = event.target.files[0];
	var reader = new FileReader();
	var img = document.getElementById('image');

	if (VS.global.reset) {
		VS.global.vyi = { 'v': 1, 'i': [] };
		VS.global.vys = '';
		VS.global.fileName = null;
		VS.global.type = null;
		VS.global.rideAlong = null;
		VS.global.firstTypeAdded = false;

		VS.global.name = null;
		VS.global.width = null;
		VS.global.height = null;

		VS.global.rideAlong = VS.global.client.confirm('Would you like to witness each sprite cut and determine if its a frame or icon state, as well as define its type? \n\n OK: Yes\n\n Cancel: No (all sprites will be its own icon and all diobs will be of ' + VS.global.defaultType + ' baseType)');
		VS.global.width = VS.global.client.prompt('Width of sprites in tileset?', 24);
		VS.global.height = VS.global.client.prompt('Height of sprites in tileset?', 24);

		VS.global.width = Number(VS.global.width);
		VS.global.height = Number(VS.global.height);

		if (!VS.global.width || !VS.global.height) {
			return VS.World.kickClient(VS.global.client, 'A number was not inputted for the width or height of the sprites');
		}

		VS.global.preview_canvas.text = VS.global.preview_canvas.defaultText;
		VS.global.preview_canvas2.text = VS.global.preview_canvas2.defaultText;

		VS.global.preview_canvas.width = VS.global.width * 2;
		VS.global.preview_canvas.height = VS.global.height * 2;

		VS.global.preview_canvas2.width = VS.global.width * 2;
		VS.global.preview_canvas2.height = VS.global.height * 2;

		makeWorker({'w': VS.global.width, 'h': VS.global.height});

		if (!VS.Util.isNumber(VS.global.width) || !VS.Util.isNumber(VS.global.height) ) {
			return VS.World.kickClient(VS.global.client, 'A number was not inputted for the width or height of the sprites')
		}

		if (!VS.global.rideAlong) {
			VS.global.name = VS.global.client.prompt('Name to be used for all diobs with a variable counter appended to the end: ', 'NamelessDiob')
			if (!VS.global.name) {
				VS.global.name = 'NamelessDiob'
			}
		}
	}

	if (selectedFile) {
		VS.global.vyi = {'v': 1,'i': []}
		var extension = event.target.files[0].name.split('.').pop();
		VS.global.fileName = event.target.files[0].name.replace('.' + extension, '');
	}

	if (event.target.files.length === 1) {
		if (extension !== 'jpg' && extension !== 'jpeg' && extension !== 'png') { /* If one of the files extension is not = to the supported types */
			return

		} else if (extension === 'png' || extension === 'jpg' || extension === 'jpeg') {
			img.title = 'Uploaded image: ' + selectedFile.name;

			reader.onload = function(event) {
				img.src = event.target.result;
			}
			reader.readAsDataURL(selectedFile);
		}
	}
}

function drawImgToCanvas() {
	var image = document.getElementById('image');
	var canvas = document.getElementById('canvas');
	var ctx = canvas.getContext('2d');

	canvas.width = image.width;
	canvas.height = image.height;

	VS.global.canvas.width = canvas.width + 40;
	VS.global.canvas.height = canvas.height + 40;
	ctx.drawImage(image, 0, 0, canvas.width, canvas.height);

	setTimeout(function() {
		var bitmap = createImageBitmap(canvas, 0, 0, canvas.width, canvas.height);
		bitmap.then(function(result) {
			WORKER.postMessage({ 'msg': 'image', 'bitmap': result });
			WORKER2.postMessage({ 'msg': 'image', 'bitmap': result });
			VS.global.makeVyi();
		});		
	}, 500);
}

#END JAVASCRIPT
