# Test script for calc_server.py.
# Requires that the web service is running.

import urllib

######
### SVG rendering.
print "SVG rendering:"

testmolfile = """
     RDKit

  5  4  0  0  0  0  0  0  0  0999 V2000
    0.0000    0.0000    0.0000 N   0  0  0  0  0  0  0  0  0  0  0  0
    0.0000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
    0.0000    0.0000    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
    0.0000    0.0000    0.0000 O   0  0  0  0  0  0  0  0  0  0  0  0
    0.0000    0.0000    0.0000 O   0  0  0  0  0  0  0  0  0  0  0  0
  1  2  1  0
  2  3  1  0
  3  4  2  0
  3  5  1  0
M  END
"""

qs = urllib.urlencode({'molfile': testmolfile, 'width': 400, 'height': 200})
r = urllib.urlopen("http://localhost:8080/run/render", qs)
s = r.read()
print s[:300] + "\n...\n" + s[-50:]
print

######
### Fragment count.
print "Fragment counts (you should see output counts of 1, 2, and 3):"

fragcount1 = """
     RDKit

  3  2  0  0  0  0  0  0  0  0999 V2000
   -3.1583    0.8458    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
   -2.4458    1.2583    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
   -1.7333    0.8500    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
  1  2  1  0  0  0  0
  2  3  1  0  0  0  0
M  END
"""

qs = urllib.urlencode({'molfile': fragcount1})
r = urllib.urlopen("http://localhost:8080/run/fragment_count", qs)
s = r.read()
print s

fragcount2 = """
     RDKit

  5  3  0  0  0  0  0  0  0  0999 V2000
   -3.1583    0.8458    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
   -2.4458    1.2583    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
   -1.7333    0.8500    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
   -3.0042   -0.8083    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
   -2.2897   -0.3958    0.0000 Cl  0  0  0  0  0  0  0  0  0  0  0  0
  2  3  1  0  0  0  0
  1  2  1  0  0  0  0
  4  5  1  0  0  0  0
M  END
"""

qs = urllib.urlencode({'molfile': fragcount2})
r = urllib.urlopen("http://localhost:8080/run/fragment_count", qs)
s = r.read()
print s

fragcount3 = """
     RDKit

  7  4  0  0  0  0  0  0  0  0999 V2000
   -3.1583    0.8458    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
   -2.4458    1.2583    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
   -1.7333    0.8500    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
   -3.0042   -0.8083    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
   -2.2897   -0.3958    0.0000 Cl  0  0  0  0  0  0  0  0  0  0  0  0
   -3.0333   -1.9333    0.0000 F   0  0  0  0  0  0  0  0  0  0  0  0
   -2.3189   -1.5208    0.0000 C   0  0  0  0  0  0  0  0  0  0  0  0
  2  3  1  0  0  0  0
  4  5  1  0  0  0  0
  1  2  1  0  0  0  0
  6  7  1  0  0  0  0
M  END
"""

qs = urllib.urlencode({'molfile': fragcount3})
r = urllib.urlopen("http://localhost:8080/run/fragment_count", qs)
s = r.read()
print s

print "== Done."
