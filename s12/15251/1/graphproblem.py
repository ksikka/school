class Room:

  def __init__(self, id, colors=None):
    self.id = id
    self.colors = colors

  def isDeadEnd(self):
    if colors is None:
      return True
    else:
      return False

class Passageway:

  def __init__(self, v1, v2, color):
    self.v1 = v1
    self.v2 = v2
    self.color = color
  

rooms = []
passageways = []
vHash = []

infile = open(filename, "r")
# this is for rooms
numRooms = int(infile.readline())
print numRooms
for count in numRooms:
  line = infile.readline()
  words = line.split(" ")
  vertex = Room(int(words[0]), words[1], words[2:7] ]) #id, message, colors
  rooms.append(vertex)
  vHash[vertex.id] = vertex
# this is for passageways
numPassageways = int(infile.readline())
print numPassageways
for count in numPassageways:
  line = infile.readline()
  words = line.split(" ")
