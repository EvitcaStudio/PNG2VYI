onmessage = function(e) {
	switch (e.data.msg) {
		case 'setup':
			self.canvas = e.data.canvas;
			self.context = self.canvas.getContext('2d');
			self.canvas.width = e.data.json.w;
			self.canvas.height = e.data.json.h;
			self.width = e.data.json.w;
			self.height = e.data.json.h;
			break;

		case 'image':
			self.bitmap = e.data.bitmap;
			break;

		case 'drawPreview':
			self.canvas.width = self.width;
			self.canvas.height = self.canvas.height;
			self.context.drawImage(self.bitmap, e.data.x, e.data.y, self.width, self.height, 0, 0, self.canvas.width, self.canvas.height);
			break;

		case 'getBlob':
			self.canvas.convertToBlob().then(function(blob) {
				if (e.data.state) {
					postMessage({ 'msg': 'blob', 'blob': blob, 'array': e.data.array, 'count': e.data.count, 'type': 'state' });
					return
				}

				if (e.data.frame) {
					postMessage({ 'msg': 'blob', 'blob': blob, 'array': e.data.array, 'count': e.data.count, 'type': 'frame' });
					return
				}

				if (e.data.state_frame) {
					postMessage({ 'msg': 'blob', 'blob': blob, 'array': e.data.array, 'count': e.data.count, 'type': 'state_frame', 'state_count': e.data.state_count });
					return					
				}

				postMessage({ 'msg': 'blob', 'blob': blob, 'array': e.data.array });
			});
	}
}