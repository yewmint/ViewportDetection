getRdians = (x1, y1, x2, y2)->
  dx = x2 - x1
  dy = y2 - y1
  Math.atan2(dy, dx)

getIntersection = (ray, segment)->

  if segment.isCollision is off then return null

  r_px = ray.a.x
  r_py = ray.a.y
  r_dx = ray.b.x - ray.a.x
  r_dy = ray.b.y - ray.a.y

  s_px = segment.a.x
  s_py = segment.a.y
  s_dx = segment.b.x - segment.a.x
  s_dy = segment.b.y - segment.a.y

#  r_mag = Math.sqrt(r_dx*r_dx+r_dy*r_dy)
#  s_mag = Math.sqrt(s_dx*s_dx+s_dy*s_dy)
#  if(r_dx/r_mag==s_dx/s_mag && r_dy/r_mag==s_dy/s_mag)
#    return null

  H = s_dx * r_dy - r_dx * s_dy

#  if s_px is 50 and s_dx is 50 and r_px is 100 and r_dx is 0
#    console.log H

  if H is 0
    return null

  Hrt = s_dx * (s_py - r_py) - s_dy * (s_px - r_px)
  Hst = r_dx * (s_py - r_py) - r_dy * (s_px - r_px)
#  T2 = (r_dx*(s_py-r_py) + r_dy*(r_px-s_px))/(s_dx*r_dy - s_dy*r_dx)
#  T1 = (s_px+s_dx*T2-r_px)/r_dx

  rt = Hrt / H
  st = Hst / H

  if rt < 0 then return null
  if st < 0 || st > 1 then return null

  return {
    x: Math.round(r_px + r_dx * rt)
    y: Math.round(r_py + r_dy * rt)
    distance: Math.sqrt(Math.pow(r_dx * rt, 2) + Math.pow(r_dy * rt, 2))
  }

class Point
  constructor: (@x, @y)->

class Segment
  constructor: (x1, y1, x2, y2, @isCollision)->
    @a = new Point x1, y1
    @b = new Point x2, y2

class Ray
  constructor: (x1, y1, x2, y2)->
    @a = new Point x1, y1
    @b = new Point x2, y2

class Polygon
  constructor: (points)->
    @points = points.slice 0
    @segments = []
    @points.forEach (elem, index, arr)=>
      curPoint = arr[index]
      nextPoint = arr[(index + 1) % arr.length]
      @segments.push(new Segment(curPoint.x, curPoint.y, nextPoint.x, nextPoint.y, true))
    @pointSegmentSets = []
    @points.forEach (elem, index, arr)=>
      @pointSegmentSets.push({
        point: elem
        segments: [ @segments[(index - 1 + arr.length) % arr.length], @segments[index] ]
      })

polygons = [
  new Polygon([
    new Point(0, 0)
    new Point(700, 0)
    new Point(700, 480)
    new Point(0, 480)
  ])
  new Polygon([
    new Point(140, 230)
    new Point(140, 180)
    new Point(90, 180)
    new Point(90, 230)
  ])
  new Polygon([
    new Point(640, 230)
    new Point(640, 180)
    new Point(590, 180)
    new Point(590, 230)
  ])
  new Polygon([
    new Point(50, 50)
    new Point(100, 50)
    new Point(50, 100)
  ])
  new Polygon([
    new Point(380, 300)
    new Point(439, 280)
    new Point(465, 77)
    new Point(200, 180)
    new Point(220, 250)
  ])
  new Polygon([
    new Point(630, 400)
    new Point(600, 280)
    new Point(550, 360)
  ])
  new Polygon([
    new Point(80, 400)
    new Point(200, 380)
    new Point(150, 430)
  ])
]

canvas = document.getElementById("ray")
ctx = canvas.getContext("2d")

getCursor = (x, y)->
  bbox = canvas.getBoundingClientRect()
  return {
    x: x - bbox.left * (canvas.width / bbox.width) || 0
    y: y - bbox.top  * (canvas.height / bbox.height) || 0
  }

clearCanvas = ()->
  ctx.clearRect(0, 0, 700, 480)

drawPoint = (point)->
  ctx.fillStyle = "#FF0000"
  ctx.beginPath()
  ctx.arc(point.x, point.y, 5, 0, 2*Math.PI)
  ctx.fill()

drawSegment = (segment, color = "#888888")->
  ctx.beginPath()
  ctx.strokeStyle = color
  ctx.moveTo(segment.a.x, segment.a.y)
  ctx.lineTo(segment.b.x, segment.b.y)
  ctx.stroke()

drawPolygon = (polygon)->
  for segment in polygon.segments
    drawSegment(segment)

intersections = []

sortIntersections = (ox, oy)->
  intersections.sort((a, b)-> a[0].radians - b[0].radians)

drawFill = (ox, oy)->
  ctx.beginPath()
  ctx.fillStyle = "rgba(255, 155, 155, 0.8)"
  ctx.moveTo(ox, oy)
  for ints in intersections
    for point in ints
      ctx.lineTo(point.x, point.y)
  ctx.lineTo(intersections[0][0].x, intersections[0][0].y)
  ctx.fill()

drawCast = (ox, oy)->
  for ints in intersections
    for point in ints
      drawSegment(new Segment(ox, oy, point.x, point.y), "#ff5d69")
      drawPoint(point)

raycastPolygons = (ray)->
  intersection = null
  for polygon in polygons
    for segment in polygon.segments
      newIntersection = getIntersection(ray, segment)
      if newIntersection is null then continue
      if intersection is null or intersection.distance > newIntersection.distance
        intersection = newIntersection
  return intersection

cast = (cursorX, cursorY)->
  intersections = []
  # paint
  clearCanvas()
  for polygon in polygons
    drawPolygon(polygon)
  # cast
  for polygon in polygons
    for psSet in polygon.pointSegmentSets
      # first cast
      ints = []
      ray = new Ray(cursorX, cursorY, psSet.point.x, psSet.point.y)
      radians = getRdians(ray.a.x, ray.a.y, ray.b.x, ray.b.y)
      angles = [radians - 0.00001, radians, radians + 0.00001]
      for angle in angles
        dx = Math.cos(angle)
        dy = Math.sin(angle)
        ray.b.x = psSet.point.x + dx
        ray.b.y = psSet.point.y + dy
        intersection = raycastPolygons(ray)
        if intersection
          intersection.radians = radians
          ints.push(intersection)
      intersections.push(ints)

readyToPaint = true

for polygon in polygons
  drawPolygon(polygon)

cast(100, 100)
sortIntersections(100, 100)
drawFill(100, 100)
drawCast(100, 100)

canvas.addEventListener("mousemove", (e)->
  if not readyToPaint then return
  cursor = getCursor(e.clientX, e.clientY)
  cast(cursor.x, cursor.y)
  sortIntersections(cursor.x, cursor.y)
  drawFill(cursor.x, cursor.y)
  drawCast(cursor.x, cursor.y)
  readyToPaint = false
  requestAnimationFrame(()-> readyToPaint = true)
, false);