class_name TerrainChunk
extends MeshInstance3D

const EXTRACTOR = preload("res://moon/extractor.tscn")
const TELEPORT = preload("res://prototype/teleport.tscn")

@export var max_height_limit := 1
@export var min_height_limit := -1

var chunk_size := 32  # Number of vertices per side
var resolution := 1.0  # Space between vertices
var noise_height := 10
var noise: Noise
var chunk_position := Vector2()

func generate_chunk():
	create_mesh()
	add_collision()

	if chunk_position == Vector2.ZERO:
		_create_pod()
		_create_teleport()

func _create_pod():
	var pod = EXTRACTOR.instantiate()
	pod.position.y = get_height(0, 0)
	add_child(pod)
	
func _create_teleport():
	var pod = TELEPORT.instantiate()
	pod.position = Vector3(0, get_height(0, 5), 5)
	add_child(pod)

func create_mesh():
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_smooth_group(-1)
	
	# Generate vertices
	for z in chunk_size:
		for x in chunk_size:
			var height = get_height(x, z)
			var vertex = Vector3(x * resolution, height, z * resolution)
			
			surface_tool.add_vertex(vertex)
	
	# Generate indices (triangle strips)
	for z in chunk_size - 1:
		for x in chunk_size - 1:
			var top_left = z * chunk_size + x
			var top_right = top_left + 1
			var bottom_left = (z + 1) * chunk_size + x
			var bottom_right = bottom_left + 1
			
			# First triangle
			surface_tool.add_index(top_left)
			surface_tool.add_index(top_right)
			surface_tool.add_index(bottom_left)
			
			# Second triangle
			surface_tool.add_index(top_right)
			surface_tool.add_index(bottom_right)
			surface_tool.add_index(bottom_left)
	
	surface_tool.generate_normals()
	mesh = surface_tool.commit()

func get_height(x, z):
	var world_x = chunk_position.x * (chunk_size - 1) + x
	var world_z = chunk_position.y * (chunk_size - 1) + z
	var h = noise.get_noise_2d(world_x, world_z)
	h = clamp(h, min_height_limit, max_height_limit)
	
	return h * noise_height

func add_collision():
	var static_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = mesh.create_trimesh_shape()
	collision_shape.shape = shape
	static_body.add_child(collision_shape)
	add_child(static_body)

#func populate_stones():
	#var multi_mesh = MultiMeshInstance3D.new()
	#multi_mesh.multimesh = MultiMesh.new()
	#multi_mesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	#
	#var scatter_pos = {}
	#for z in chunk_size:
		#for x in chunk_size:
			#var scatter = scatter_noise.get_noise_2d(x, z)
			#if scatter >= min_scatter and scatter <= max_scatter:
				#scatter_pos[Vector2(x, z)] = 1
	#
	#multi_mesh.multimesh.instance_count = scatter_pos.values().reduce((func(a, b): return a + b), 0)
	#multi_mesh.multimesh.mesh = BoxMesh.new()
	#multi_mesh.multimesh.mesh.size = Vector3(0.1, 0.1, 0.1)
#
	#var rng = RandomNumberGenerator.new()
	#rng.seed = hash(chunk_position)
	#
	#var instance_id = 0
	#for pos in scatter_pos.keys():
		#for i in scatter_pos[pos]:
			#var height = get_height(pos.x, pos.y)
			#var mesh_trans = Transform3D()
			##.scaled(Vector3(
				##0.1 + rng.randf_range(-0.05, 0.05),
				##0.1 + rng.randf_range(-0.1, 0.1),
				##0.1 + rng.randf_range(-0.05, 0.05)
			##))
			#
			#mesh_trans = mesh_trans.rotated(Vector3.UP, rng.randf_range(0, 2 * PI))
			#mesh_trans.origin = Vector3(pos.x * resolution, height, pos.y * resolution)
			#multi_mesh.multimesh.set_instance_transform(instance_id, mesh_trans)
			#instance_id += 1
	#
	#add_child(multi_mesh)
