#!/usr/bin/python
import time
import BaseHTTPServer

import sys, os
import urlparse

from rdkit import Chem
from rdkit.Chem import Draw
from rdkit.Chem.Draw import rdMolDraw2D

import json

HOST_NAME = ''
PORT_NUMBER = 8080

class MyHandler(BaseHTTPServer.BaseHTTPRequestHandler):
	# We only implement GET and POST. HEAD etc. will be ignored
	# (or served in whatever default way the BaseHTTPServer
	# provides).

	def send_200(self):
		self.send_response(200)
		self.send_header("Content-type", "text/plain")
		self.end_headers()
		return

	def send_500(self):
		self.send_response(500)
		self.send_header("Content-type", "text/plain")
		self.end_headers()
		self.wfile.write(str(sys.exc_info()[1]))
		return


	def do_GET(self):
		try:
			urlcomponents = urlparse.urlparse(self.path)
			params = urlparse.parse_qs(urlcomponents.query)
			base_path =  urlparse.urlparse(self.path).path

			d = self.pathdelegate(params, base_path)
			#Convert to JSON and write to client
			j = json.dumps(d)
			self.send_200()
			self.wfile.write(j)
		except:
			self.send_500()
			
	def do_POST(self):
		try:
			raw_data_size = int(self.headers.get('Content-Length'))
			raw_data = self.rfile.read(raw_data_size).decode('utf-8')
			params = urlparse.parse_qs(raw_data)

			base_path =  urlparse.urlparse(self.path).path
			#Get a dictionary with the result from the delegate function
			d = self.pathdelegate(params, base_path)
			#Convert to JSON and write to client
			if d != None:
				j = json.dumps(d)
				self.send_200()
				self.wfile.write(j)
			return
		except:
			self.send_500()
		return


	def test_concurrency(self, params, d):
        	print "Entered request handler"
        	time.sleep(2)
        	print "Sending response!"
		return d

	def render(self, params, d):
		molfile = params['molfile'][0]
		svg_width = int(params['width'][0])
		svg_height = int(params['height'][0])

		print "Render (" + str(svg_width) + ", " + str(svg_height) + ") image of '" + molfile[0:30].replace('\n', ' ') + "...'"

		mol = Chem.MolFromMolBlock(molfile, sanitize = False)
		if mol == None:
			raise Exception ("Unable to read molfile.")
		# Update valences etc. so drawing code doesn't choke on the non-sanitized input.
		mol.UpdatePropertyCache(strict=False)
		# And ring info also needs to be there.
		Chem.rdmolops.GetSSSR(mol)

		rdMolDraw2D.PrepareMolForDrawing(mol)
		drawer = rdMolDraw2D.MolDraw2DSVG(svg_width, svg_height)
		drawer.DrawMolecule(mol)
		drawer.FinishDrawing()
		svg = drawer.GetDrawingText()

		d['svg'] = svg
		return d

	def fragment_count(self, params, d):
		molfile = params['molfile'][0]

		print "fragment count of '" + molfile[0:30].replace('\n', ' ') + "...'"

		mol = Chem.MolFromMolBlock(molfile)
		if mol == None:
			raise Exception ("Unable to read molfile.")

		d['fragment_count'] = len(Chem.GetMolFrags(mol))
		return d

	def pathdelegate(self, params, path):
		d = dict() # create a dictionary to collect the results

		if path == '/run/render':
			return self.render(params, d)
		elif path == '/run/fragment_count':
			return self.fragment_count(params, d)
		elif path == '/test/concurrency':
			return self.test_concurrency(params, d)
		else:
			self.send_response(404)
			self.send_header("Content-type", "text/plain")
			self.end_headers()
			self.wfile.write("Path not found.\n")

# Making a forked HTTPserver class.
from SocketServer import ForkingMixIn

class ForkedHTTPServer(ForkingMixIn, BaseHTTPServer.HTTPServer):
	max_children=4 #default 40
	def sighup(self, signum, frame):
        	print "Received Signal: %s at frame: %s" % (signum, frame)
		print time.asctime(), "Server Stops - %s:%s" % (HOST_NAME, PORT_NUMBER)
		self.server_close() #This closes fine when called via httpd.sighub after Ctrl-C, but not when kill -s HUP pid????

def stop_server(httpd):
	httpd.server_close()
	
import signal

if __name__ == '__main__':
	server_class = ForkedHTTPServer
	httpd = server_class((HOST_NAME, PORT_NUMBER), MyHandler)
	print time.asctime(), "Server Starts - %s:%s" % (HOST_NAME, PORT_NUMBER)
	#Register signal to stop server
	signal.signal(signal.SIGHUP, httpd.sighup)
	try:
		httpd.serve_forever()
	except KeyboardInterrupt:
		pass
	httpd.sighup(None,None) #stop_server(httpd)
