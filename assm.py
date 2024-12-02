# Run this script with XAS99 to assemble all files
# See https://endlos99.github.io/xdt99/
#
# If you can't run powershell scripts research this command locally:
# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
import os, glob
from itertools import chain

#Functions
WORK_FOLDER = "./bin/"
os.makedirs(WORK_FOLDER, exist_ok=True)

def get_work_file(filename):
    return WORK_FOLDER + filename

def get_unlinked_string(object_files):
    unlinked_files = []
    for object_file in object_files:
        unlinked_files.append(get_work_file(object_file + ".obj"))
    return " ".join(unlinked_files)

def link_main_files(linked_file, object_files):
    unlinked_files_string = get_unlinked_string(object_files)
    link_command_1 = "xas99.py -b -a \">6000\" -l {source} -o {output}"
    link_command_2 = link_command_1.format(source = unlinked_files_string, output = get_work_file(linked_file))
    os.system(link_command_2)
    rpk_link_1 = "xas99.py -c -a \">6000\" -l {source} -o {output}"
    rpk_link_2 = rpk_link_1.format(source = unlinked_files_string, output = get_work_file(linked_file.replace(".bin", ".rpk")))
    os.system(rpk_link_2)

#Assemble Src and Tests
files = os.scandir(".//Src")

for file_obj in files:
    print("Assembling " + file_obj.path)
    list_file = get_work_file(file_obj.name.replace(".asm", ".lst"))
    obj_file = get_work_file(file_obj.name.replace(".asm", ".obj"))
    assemble_command_1 = "xas99.py {source} -S -R -L {list} -o {object}"
    assemble_command_2 = assemble_command_1.format(source = file_obj.path, list = list_file, object = obj_file)
    os.system(assemble_command_2)

print("Linking Main Program")
temp_files = [
    "CART",
    "GROM",
    "MAIN",
    "VDP",
    "LOGINTERRUPTS",
    "PIXELROW",
    "TILES",
    "FOURPARTTEXT",
    "FONTS",
    "KEY"
]
link_main_files("midFrame.bin", temp_files)

#Clean up
# for file in glob.glob(WORK_FOLDER + "*.lst"):
#     os.remove(file)
for file in glob.glob(WORK_FOLDER + "*.obj"):
    os.remove(file)