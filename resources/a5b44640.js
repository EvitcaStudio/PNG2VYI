onmessage = function(e) {
	switch (e.data.msg) {
		case 'setup2':
			self.canvas2 = e.data.canvas;
			self.canvas2.width = e.data.json.w;
			self.canvas2.height = e.data.json.h;
			self.width = e.data.json.w;
			self.height = e.data.json.h;
			self.context2 = self.canvas2.getContext('2d');
			self.context2.fillRect(0, 0, 0, 0);
			self.context2.clearRect(0, 0, self.width, self.height);
			break;

		case 'image':
			self.bitmap = e.data.bitmap;
			break;

		case 'drawPrevious':
			if (e.data.previous) {
				self.canvas2.width = self.width;
				self.canvas2.height = self.height;
				self.context2.drawImage(self.bitmap, e.data.previous['x'], e.data.previous['y'], self.width, self.height, 0, 0, self.canvas2.width, self.canvas2.height);
			}
			break;
	}
}