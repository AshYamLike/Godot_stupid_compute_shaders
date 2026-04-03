# Godot_stupid_compute_shaders
An overall bad abstraction over Godot 4's Compute Shader API simplifying the process of creating and running compute shaders. Allowing for GLSL code to be run in parallel on large chunks of data without going insane... too much

## How to install it
Drag the folder "Stupid_compute_shader" into your "addons" folder in your godot project. After that enable the addon by going to Project -> Project Settings -> Plugins. If this explanation was a little too unclear see the [Godot plugin docs](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html)


## How to use the StupidComputeShader node
1. Add the StupidComputeShader node to your scene 
2. Select a GLSL file in the editor (you can skip this step for now if you want to generate one)
3. Give the shader a unique ID by setting the Shader_Id variable in the editor (it will be used to set the binding for the shader)
4. Set the data the shader will use by giving the Data array values in your script (either floats or ints and it can be of any size your hardware will allow)
5. Call the .run method on the node. For example: `stupid_compute_node_name.run()` and saving the return value of that function as output

### Example Usage
```GDScript
extends Node2D

@onready var stupid_compute_shader: StupidComputeShader = $StupidComputeShader

func _ready() -> void:
	#Sets the data that will be contained in the buffer the shader will use
	stupid_compute_shader.Data = [1.0,2.0,3.0]
	#Stores the buffer (now modified) in modified_storage_buffer
	var modified_storage_buffer = stupid_compute_shader.run()
	print(modified_storage_buffer)
```

## How to generate GLSL code from StupidComputeShader node in the editor
1. Select the StupidComputeShader node that you want a GLSL file for
2. Click on the Create File checkbox in the Inspector (don't worry if it doesn't appear checked, its value gets put back to false after the file is generated)
3. Open the file in an external text editor and make the changes you want

Note: Godot will sometimes not import the file automatically with this method so you might have close and then reopen the project before it appears in the editor
Note 2: If you want you can also copy the Generated_Glsl text into a file manually, it'll get you to the same place


### Example of generated GLSL file
```GLSL
#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 2, std430) restrict buffer DataBuffer {
	float data[]; //Think of this as a struct with only one member

}data_buffer; //Creates one instance of this so called 'struct'


// The code we want to execute in each invocation or 'thread'
void main() {
	// gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups 
	// data is an array inside data_buffer that contains all input data and can be written to as well (at the end of the shader it will be returned as the output)
	uint idx = gl_GlobalInvocationID.x; //idx is the current index
	float current_value = data_buffer.data[idx];
}

```
### Example GLSL usage
```GLSL
#[compute]
#version 450

layout(local_size_x = 64, local_size_y = 1, local_size_z = 1) in;

layout(set = 0, binding = 2, std430) restrict buffer DataBuffer {
	float data[];

}data_buffer; 


void main() {

	uint idx = gl_GlobalInvocationID.x; 
	float current_value = data_buffer.data[idx];

    //Assign new value to data at idx(current data being worked on for this invocation)
    data_buffer.data[idx] = 100.0;

    //Reads current value and checks if it equals 2.0
    if (current_value == 2.0){
        data_buffer.data[idx] = 200;
    }

}
```

## Legacy: How to generate GLSL code from StupidComputeShader in a big batch (all StupidComputeShader nodes will be given a GLSL file)
1. In your addons folder look for the "Stupid_compute_shader" folder and open the script generate_glsl_file.gd
2. Navigate to the scene that contains one or more StupidComputeShader nodes (set these nodes up the way you want just leave the GLSL_File variables empty for now) 
3. Open the generate_glsl_file.gd script while also having your scene open containing the StupidComputeShader node (make sure when you go to 2D/3D view the scene with the StupidComputeShader node is the one that appears)
4. Go to the script view and press Ctrl + Shift + x
5. Open the project in a file manager and check if the GLSL file is generated for you (it will have the same name as your StupidComputeShader node and be located in the root of the directory)


## Stuff thats coming (probably)
- More error checking


## License

This project includes code from the Godot Engine documentation which is licensed under the MIT License.
Copyright (c) 2014-present Godot Engine contributors.
See: https://godotengine.org/license
