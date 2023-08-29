# HTML Canvas Viewer

This viewer renders the `r_place.json` file created by the `rp_export_json` mod when
hosted over HTTP[s], directly in a browser.

- Publicly host the r_place.json file on your web server.
- Host this file next to it (in the same path).
	- ...or, modify the `url` variable in the code to point to where your
	  `r_place.json` file will be hosted.
	- If you host r_place.json and the viewer html on different domains,
	  remember to add CORS headers to your r_place.json web host configuration
	  or else the viewer will be unable to fetch the JSON data.

The page layout is designed around a "fit to frame" large viewer, but you can also
embed the javascript code and the canvas element on any other page.

The page will automatically refresh the canvas data every minute (60000ms).  You can
disable this by deleting the `setInterval` line of code, or change the interval (but
note the potential impact on your web server).  Note that there is a delay after
loading the page (e.g. after a manual refresh) before the image is available, so the
auto-refresh may be a better experience for users.
