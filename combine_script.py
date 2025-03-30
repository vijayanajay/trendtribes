import os


def combine_python_files(output_filename="combined_code.txt"):
    """
    Combines all .py files in the current directory and its subdirectories
    into a single text file, preserving formatting and indicating the
    directory structure.  The script itself is excluded from the output.

    Args:
        output_filename: The name of the output text file.
    """

    script_name = os.path.basename(__file__)  # Get the name of this script
    all_files = []

    for dirpath, dirnames, filenames in os.walk("."):
        for filename in filenames:
            # print (dirpath)
            if (filename.endswith((".py")) and filename != script_name) or (
                filename.endswith((".tsx", ".css", ".js"))
                and dirpath
                in (
                    ".\\frontend\\src\\app",
                    ".",
                    ".\\frontend\\src\\components",
                )
            ):
                all_files.append(os.path.join(dirpath, filename))
    print(all_files)
    with open(output_filename, "w") as outfile:
        for filepath in all_files:
            relative_path = os.path.relpath(
                filepath, "."
            )  # Get path relative to current dir
            outfile.write(f"### File: {relative_path}\n\n")
            print(f"### File: {relative_path}\n\n")

            with open(filepath, "r") as infile:
                outfile.write(infile.read())

            # Separator between files
            outfile.write("\n\n" + ("=" * 50) + "\n\n")

    print(f"Combined code written to {output_filename}")
    # Created/Modified files during execution:
    print(f'["{output_filename}"]')


if __name__ == "__main__":
    combine_python_files()
