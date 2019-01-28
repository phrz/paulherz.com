---
layout: post
title:  "From bitmap to .bmp"
date:   2019-01-27 16:00:00 -0600
author: "Paul Herz"
categories: snippets
---

{% assign post_assets = 'assets/posts/from-bitmap-to-bmp' %}

Building images with code is a hobby of mine. In Python, generating images with <a href="https://python-pillow.org">Pillow</a> is very easy. All you have to do is generate the image's bytes and pass it to an Image object.

I wanted to see how this could be done at a very low level in JavaScript. You can use the Canvas and draw one-pixel rectangles, or just use WebGL, but I chose to go lower. Instead, I ended up converting a raw image to a BMP file (think Windows Paint), and displaying it directly within an `<img>` tag. The BMP format seemed like the simplest image format that worked in web browsers.

> Quick note: I know this is not anywhere near efficient. It computes the value of every pixel serially on the CPU and stores it in an uncompressed BMP file represented in base64. This is a starting point to learning and demonstrating better ways of doing these, e.g. with WebGL and shaders.

I used <a href="http://www.dragonwins.com/domains/GetTechEd/bmp/bmpfileformat.htm">this page</a> to reference the BMP image format. A Windows BMP file begins with the File Header, followed by the Image Header. I'm only creating true color, 24-bit RGB images, so the palette section is unnecessary.

The image's pixels follow, from the bottom row to the top, from the left to the right column. There is one byte for each component of the pixel, red, green, and blue.

# Serialization

I will represent all binary file data as arrays of numeric bytes. The BMP format uses little-endian numbers in its headers, either 16- or 32-bit length. I will create functions to break up integers into bytes.

```js
function num_to_u32_le(x) {
	if(x < 0 || x > Math.pow(2,32) - 1) {
		console.error(`Overflow: ${x} is too large for a u32.`);
		return [0,0,0,0];
	}
	const ff = 0xFF;
	return [
		x & 0xFF, (x >> 8) & 0xFF, 
		(x >> 16) & 0xFF, (x >> 24) & 0xFF
	];
}

function num_to_u16_le(x) {
	if(x < 0 || x > Math.pow(2,16) - 1) {
		console.error(`Overflow: ${x} is too large for a u16.`);
		return [0,0];
	}
	return [x & 0xFF, (x >> 8) & 0xFF];
}
```

The following are convenience functions which take a variadic list of numbers and pushes the converted bytes to the given array.

```js
const push_u32_le = (arr, ...xs) => arr.concat(...xs.map(num_to_u32_le));
const push_u16_le = (arr, ...xs) => arr.concat(...xs.map(num_to_u16_le));
```

# The file header

The BMP file header begins with the ASCII literal "BM". It's followed by the total file size, two reserved fields (which should remain zero), and the starting position of the actual image pixels. I break this off into a function:

```js
function bmp_file_header(pixelStartAddress, fileSize) {
	let data = [0x42, 0x4D]; // 'BM'

	const reserved = 0; // must be zero

	data = push_u32_le(data, fileSize);
	data = push_u16_le(data, reserved, reserved);
	data = push_u32_le(data, pixelStartAddress);
	return data;
}
```

# The image header

The image header stores information particular to the image itself, and it is not quite as minimal as the file header.

This header stores a lot of unused information, particularly in the case of a 24-bit true color image. The useful items are the header's size, the image dimensions, and bits per pixel. I have defined many headers as variables for clarity, despite many not being useful.

We are not compressing the image data, so the compression field and uncompressed size field can both be zero. The "planes" field must be one. The "pixels per meter" fields (x and y) are physical size hints, and therefore useless. The color map fields are similarly unused.

```js
function bmp_image_header(width, height, bitsPerPixel) {
	let data = []; 

	const imageHeaderSize = 40;
	// must be 1
	const planes = 1; 
	// 0 = uncompressed
	const compression = 0;
	// can be 0 if uncompressed
	const imageSize = 0;
	// physical size hint (unimportant)
	const pxPerMeter = [0, 0]; 
	// true color, not needed
	const colormapEntriesUsed = 0; 
	const colormapImportant = 0;

	data = push_u32_le(
		data, imageHeaderSize, 
		width, height
	);
	data = push_u16_le(
		data, planes, bitsPerPixel
	);
	data = push_u32_le(
		data, 
		compression, 
		imageSize, 
		pxPerMeter[0], 
		pxPerMeter[1], 
		colormapEntriesUsed, 
		colormapImportant
	);
	return data;
}
```

# Converting the image buffer
From the outside, this code will accept raw image data in 24-bit RGB pixel format, going top-down, left-to-right. The given image data will be a one-dimensional number array.

However, the BMP format needs pixels from the bottom row up. My solution for flipping the one-dimensional input is a little contrived, partly because I could've written everything with 2D pixel buffers instead of 1D ones, but this code does, in fact, work.

The following function performs this flip, while additionally performing another necessity for the BMP format: each row must end on 4B (32-bit) word boundaries, so the code need to append padding bytes to make this happen.

```js
function bmp_flip_and_pad_bytes(bytes, width, height, nComponents) {
	let data = [];

	for(let r = height - 1; r >= 0; r--) {
		let rowSize = 0;
		for(let c = 0; c < width; c++) {
			for(let comp = nComponents - 1; comp >= 0; comp--) {
				rowSize++;
				data.push(
					bytes[(r * width + c)*nComponents + comp]
				);	
			} // end pixel
		} // end row

		// pad each row
		while(rowSize % 4 != 0) {
			data.push(0);
			rowSize++;
		}
	} // end image

	return data;
}
```

# Putting the file together

The following function simply combines the pieces defined above into the proper format order: file header, image header, and pixels.

```js
function bitmap(bytes, width, height) {
	const fileHeaderSize = 14;
	const imageHeaderSize = 40;
	const nComponents = 3;
	const bitsPerPixel = 24;

	const bmpPixels = 
		bmp_flip_and_pad_bytes(bytes, width, height, nComponents);
	const fileSize = 
		fileHeaderSize + imageHeaderSize + bmpPixels.length;

	let data = [].concat(
		bmp_file_header(fileHeaderSize + imageHeaderSize, fileSize),
		bmp_image_header(width, height, bitsPerPixel),
		bmpPixels
	);
	
	return data;
}
```

# Putting it in the browser

This is the layout of the overall HTML page that facilitates the JavaScript.

```html
<!doctype html>
<html>
	<head>
		<style>body{background:#999;}</style>
	</head>
	<body>
		<img id="i" style="image-rendering: pixelated;box-shadow:0 0 20px #555">
		<script>
			/* All the JavaScript */
		</script>
	</body>
</html>
```

And although I have all the functions necessary to generate the bytes of a BMP file, I need a little more code to display it as a base64 data URI: converting an array of numeric bytes to a byte string.

```js
function bytearray_to_string(a) {
	let s = '';
	for(let e of a) {
		s += String.fromCharCode(e);
	}
	return s;
}
```

I need an image to display, so I chose to generate an image where the red and green values of the pixels varies on the x and y axes, and the blue value remains constant.

```js
function rainbow255() {
	let data = [];
	for(let r = 0; r < 255; r++) {
		for(let c = 0; c < 255; c++) {
			data.push(r, c, 128);
		}
	}

	return {
		data: data,
		width: 255,
		height: 255,
	};
}
```

This final code uses all of the above to generate a base64 data URI and push it into the `<img>` element.

```js
const img = rainbow255();
const bmp = bitmap(img.data, img.width, img.height);
const byteString = bytearray_to_string(bmp);
const src = 'data:image/bmp;base64,' + btoa(byteString);

document.getElementById('i').src = src;
```

# The result

Finally, this is what all of the above code generates. I've converted it to a PNG, as the original image is 195KB, and the PNG is less than 1KB.

<img src="{{ post_assets | append: '/rainbow.png' | relative_url }}">