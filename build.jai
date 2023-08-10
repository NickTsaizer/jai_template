#import "Basic";
#import "String";
#import "File";
#import "File_Utilities";
#import "Compiler";
#import "Process";

#run
{
    make_directory_if_it_does_not_exist(join(#filepath, "modules"), true);
    make_directory_if_it_does_not_exist(join(#filepath, "binares"), true);    

    set_build_options_dc(.{do_output=false});
    
    main_workspace := compiler_create_workspace();
    if !main_workspace 
    {
        print("Couldn't create workspace to build the application!!!\n");
        exit(0);
    }
    
    build_options := get_build_options();

    modules_paths: [..] string;
    
    array_add(*modules_paths, ..build_options.import_path);
    array_add(*modules_paths, join(#filepath, "modules"));
    
    build_options.import_path = modules_paths;
    build_options.output_type = .EXECUTABLE;
    build_options.output_executable_name = path_filename(trim(#filepath, "/"));
    build_options.output_path = join(#filepath, "binares/");
	make_directory_if_it_does_not_exist(build_options.output_path);

    set_build_options(build_options, main_workspace);
    
    compiler_begin_intercept(main_workspace);
    {
        add_build_file("./src/main.jai", main_workspace);

        success_building := false;
        while true {
            message := compiler_wait_for_message();
            if !message  break;

            if message.kind == .COMPLETE 
            {
                success_building = true;
                break;
            }
        }

        if !success_building
        {
            print("We didn't succeed at building our program in workspace\n\n%\n\n", main_workspace);
            exit(0);
        }
    }
    compiler_end_intercept(main_workspace);

}