# Godot_stupid_compute_shaders
An overall bad abstraction over Godot 4's Compute Shader API simplifying the process of creating and running compute shaders. Allowing for GLSL code to be run in parallel on large chunks of data without going insane... too much

## How to install it
Drag the folder "Stupid_compute_shader" into your "addons" folder in your godot project. After that enable the addon by going to Project -> Project Settings -> Plugins. If this explanation was a little too ass see https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html


## How to use the StupidComputeShader node
1. Add the StupidComputeShader node to your scene 
2. Select a GLSL file for the compute shader in the editor or by setting the GLSL_File variables
3. Give the shader a unique ID by setting the Shader_ID variable (in the editor or in a script)
4. Set the data the shader will use by giving the Data array values (of any size just make sure you have enough vram and gpu cores)
5. Call the .run method on the node. For example: `stupid_compute_node_name.run()` and saving the return value of that function as output

## How to generate GLSL code from StupidComputeShader node in the editor
1. In your addons folder look for the "Stupid_compute_shader" folder and open the script generate_glsl_file.gd
2. Navigate to the scene that contains one or more StupidComputeShader nodes (set these nodes up the way you want just leave the GLSL_File variables empty for now) 
3. Open the generate_glsl_file.gd script while also having your scene open containing the StupidComputeShader node (make sure when you go to 2D/3D view the scene with the StupidComputeShader node is the one that appears)
4. Go to the script view and press Ctrl + Shift + x
5. Open the project in a file manager and check if the GLSL file is generated for you (it will have the same name as your StupidComputeShader node and be located in the root of the directory)

## License

This project includes code from the Godot Engine documentation which is licensed under the MIT License.
Copyright (c) 2014-present Godot Engine contributors.
See: https://godotengine.org/license
