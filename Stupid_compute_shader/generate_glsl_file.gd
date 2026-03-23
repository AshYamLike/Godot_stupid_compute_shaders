@tool
extends EditorScript

func write_glsl_file(line : String):
	pass

# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var current_scene = EditorInterface.get_edited_scene_root()
	var all_children = EditorInterface.get_edited_scene_root().get_children()
	
	for child in all_children:
		if child is StupidComputeShader:
			#Generate the glsl code... poorly
			var file = FileAccess.open("res://"+child.name+".glsl",FileAccess.WRITE)
			#This is very much stapled on
			var local_size_x : int
			var bind: int
			var set_value: int
			var data_string : String
			if child.Use_Advanced_settings:
				local_size_x = child.Invocations.x
			else:
				local_size_x = 64
				bind = child.Shader_ID
				set_value = 0
				
			if child.GLSL_datatype == child. glsl_array_datatype.int32:
				data_string = "int"
			if child.GLSL_datatype == child.glsl_array_datatype.float32:
				data_string = "float"
	
			
			#Just realized i did this in the worst possible way... well to late now
			file.store_string("#[compute]\n")
			file.store_string("#version 450\n\n")
			
			file.store_string("// Invocations in the (x, y, z) dimension\n")
			file.store_string("layout(local_size_x = "+str(local_size_x)+", local_size_y = "+str(1)+", local_size_z = "+str(1)+") in;\n\n")
			
			file.store_string("layout(set = "+str(set_value)+", binding = "+str(bind)+", std430) restrict buffer DataBuffer {\n")
			file.store_string("	"+ data_string +" data[]; //Think of this as a struct with only one member\n\n}")
			file.store_string("data_buffer; //Creates one instance of this so called 'struct'\n\n\n")
			file.store_string("// The code we want to execute in each invocation or 'thread'\n")
			file.store_string("void main() {\n")
			file.store_string("	// gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups \n")
			file.store_string("	// data is an array inside data_buffer that contains all input data and can be written to as well (at the end of the shader it will be returned as the output)\n")
			file.store_string("	uint idx = gl_GlobalInvocationID.x; //idx is the current index\n")
			file.store_string("	" + data_string + " current_value = data_buffer.data[idx];\n}")
			
			file.close()
