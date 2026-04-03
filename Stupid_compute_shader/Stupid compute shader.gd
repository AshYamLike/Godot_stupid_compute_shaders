@tool
@icon("ico.png")

#God and my gpu forgive me for this 

#Yes this is all stupid and very much stolen from the godot docs
#Yes I'm stupid

class_name StupidComputeShader
extends Node

enum glsl_array_datatype {int32,float32}

#Editor input vars
@export_category("Compute shader settings")
##The compute shader for this specific node
@export_file("*.glsl") var GLSL_File : String



##The datatype the compute shader will use 
##int32 = 4 bytes
##float32 = 4 bytes
@export var GLSL_datatype: glsl_array_datatype
@export var Shader_ID : int = 0 
##Don't set this in the editor... i mean you can but like just use code
@export var Shader_data : Array

#GLSL file creation stuff
##Generated code that should be used for this compute shader (paste this code into a external text editor and save the file in the project dir as a .glsl file)
@export_multiline var Generated_GLSL: String = ""

##If ticked (it will immediately be changed back to false so you won't see the blue tick at all) it will create a file with the name of the node plus the .glsl extention with the generated code already in it 
##Note: Godot will sometimes not import the file automatically with this method so you might have close and then reopen the project before it appears in the editor
@export var Create_file :bool = false

@export_group("Advanced")

##Tells node to use the advanced settings and ignore normal settings
@export var Use_Advanced_settings : bool = false

##The uniform type to tell the rendering device how the shader can access the created buffer
@export var Uniform_type : RenderingDevice.UniformType = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
@export var set_value : int
@export var binding_location_in_set: int

##Size of buffer in bytes
@export var Buffer_size: int = 1024
@export var Thread_groups: Vector3
@export var Invocations: Vector3
@export var GLSL_datatype_adv: glsl_array_datatype
@export_file("*.glsl") var GLSL_File_adv : String



#Runtime vars
var threadgroups : Vector3 #The amount of invocations that are run
var invocations : Vector3 #The invocations
var rendering_dev : RID

var uniform_type : RenderingDevice.UniformType #Used to tell rendering device the access type of data
var buffer_size : int
var set_val : int
var binding_val : int
var Data : Array
var Data_type : glsl_array_datatype

var glsl_file : String
var data_type_string : String

#Runtime stuff
##The rendering device used to run the compute shader
var Compute_rendering_device

func assign_vars():
	
	
	if Use_Advanced_settings == false:
		buffer_size = Data.size()*4
		set_val = 0
		binding_val = Shader_ID
		Data_type = GLSL_datatype
		uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
		threadgroups = Vector3(ceili(Data.size()/64.0),1,1)
		invocations = Vector3(64,1,1)
		var uid = ResourceUID.text_to_id(GLSL_File) 
		glsl_file = ResourceUID.get_id_path(uid) 

	else:
		buffer_size = Buffer_size
		set_val = set_value
		binding_val = binding_location_in_set
		Data_type = GLSL_datatype_adv
		uniform_type = Uniform_type
		threadgroups = Thread_groups
		invocations = Invocations
		var uid = ResourceUID.text_to_id(GLSL_File_adv) 
		glsl_file = ResourceUID.get_id_path(uid) 


func create_rendering_device() -> RenderingDevice:
	return RenderingServer.create_local_rendering_device()

func create_shader(file : String, rendering_dev : RenderingDevice) -> RID:
	var shader_file := load(glsl_file)
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	return rendering_dev.shader_create_from_spirv(shader_spirv)

func create_buffer(data : Array,rendering_dev : RenderingDevice) -> RID:
	
	# Prepare our data. We use floats in the shader, so we need 32 bit.
	if Data_type == glsl_array_datatype.int32:
		var input = PackedInt32Array(data)
		var input_bytes := input.to_byte_array()
		return rendering_dev.storage_buffer_create(input_bytes.size(), input_bytes)
	else:
		var input = PackedFloat32Array(data)
		var input_bytes := input.to_byte_array()
		return rendering_dev.storage_buffer_create(input_bytes.size(), input_bytes)

func create_uniform(uni_type: RenderingDevice.UniformType,binding: int,buffer: RID,shader:RID,rendering_dev: RenderingDevice) -> RID:
	# Create a uniform to assign the buffer to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = uni_type
	uniform.binding = binding # this needs to match the "binding" in our shader file
	uniform.add_id(buffer)
	return rendering_dev.uniform_set_create([uniform], shader, 0) # the last parameter (the 0) needs to match the "set" in our shader file



func run() -> Array:
	assign_vars()
	#Error checking
	if glsl_file == "":
		push_error("StupidComputeShader: No GLSL/Shader file specified")
	
	if buffer_size != Data.size()*4 and Use_Advanced_settings == true:
		push_error("StupidComputeShader: Size mismatch between Data Size and the actual size of data")
	
	if buffer_size == 0 and Use_Advanced_settings == true:
		push_error("StupidComputeShader: Data size is zero")
	
	
	var rd = create_rendering_device()
	var shader = create_shader(glsl_file,rd)
	var buffer = create_buffer(Data,rd)
	var uniform_set = create_uniform(uniform_type,binding_val,buffer,shader,rd)
	
	# Create a compute pipeline
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set,set_val)
	rd.compute_list_dispatch(compute_list, threadgroups.x, threadgroups.y, threadgroups.z)
	rd.compute_list_end()
	
	rd.submit()
	rd.sync()
	
	var output 
	if Data_type == glsl_array_datatype.int32:
		var output_bytes := rd.buffer_get_data(buffer)
		output = output_bytes.to_int32_array()
	if Data_type == glsl_array_datatype.float32:
		var output_bytes := rd.buffer_get_data(buffer)
		output = output_bytes.to_float32_array()
	
	rd.free_rid(uniform_set)
	rd.free_rid(pipeline)
	rd.free_rid(buffer)
	rd.free_rid(shader)
	rd.free()
	
	
	return output
#Generates glsl test
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		
		
		#This was all just modified from the legacy way of doing this so... its not great... yeah sorry
		
		var local_size_x :int 
		var bind :int
		var data_string : String = ""
				
		if Use_Advanced_settings:
			local_size_x = Invocations.x
		else:
			local_size_x = 64
			bind = Shader_ID
			set_value = 0
		
		if GLSL_datatype == glsl_array_datatype.int32:
			data_string = "int"
		if GLSL_datatype == glsl_array_datatype.float32:
			data_string = "float"
		
		var generated: String = ""

		
		#Just realized i did this in the worst possible way... well to late now
		generated = generated+"#[compute]\n"
		generated = generated+"#version 450\n\n"
		
		generated = generated+"// Invocations in the (x, y, z) dimension\n"
		generated = generated+"layout(local_size_x = "+str(local_size_x)+", local_size_y = "+str(1)+", local_size_z = "+str(1)+") in;\n\n"
		
		generated = generated+"layout(set = "+str(set_value)+", binding = "+str(bind)+", std430) restrict buffer DataBuffer {\n"
		generated = generated+"	"+ data_string +" data[]; //Think of this as a struct with only one member\n\n}"
		generated = generated+"data_buffer; //Creates one instance of this so called 'struct'\n\n\n"
		generated = generated+"// The code we want to execute in each invocation or 'thread'\n"
		generated = generated+"void main() {\n"
		generated = generated+"	// gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups \n"
		generated = generated+"	// data is an array inside data_buffer that contains all input data and can be written to as well (at the end of the shader it will be returned as the output)\n"
		generated = generated+"	uint idx = gl_GlobalInvocationID.x; //idx is the current index\n"
		generated = generated+"	" + data_string + " current_value = data_buffer.data[idx];\n}"
		Generated_GLSL = generated
		
		#Not the best I'll be first to admit but I'm tired 
		if Create_file == true:
			var file = FileAccess.open("res://"+self.name+".glsl",FileAccess.WRITE)
			file.store_string(generated)
			file.close()
			Create_file = false
