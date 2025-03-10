# Run this script with XAS99 to assemble all files
# See https://endlos99.github.io/xdt99/
#
# If you can't run powershell scripts research this command locally:
# Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
import os, glob
from itertools import chain

#Functions
VERSION = "1.0.1"
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
    rpk_link_2 = rpk_link_1.format(source = unlinked_files_string, output = get_work_file(linked_file.replace(".C.bin", ".rpk")))
    os.system(rpk_link_2)

#Generate music
music_command = (".\\score\\MusicXmlParser.exe "
    "--input score\\BunnyJump.musicxml "
    "--output src\\parallaxScroll\\TUNEBUNY.asm "
    "--asmLabel BUNY "
    "--ratio60Hz 5:4 "
    "--ratio50Hz 1:1 "
    "--repetitionType RepeatFromBeginning "
    "--displayRepoWarning false")
os.system(music_command)

#Assemble Src and Tests
for subdir, dirs, files in os.walk(".\\Src"):
    for file in files:
        if file.startswith('EQU') == False and file.endswith('MAP.asm') == False:
            filepath = subdir + os.sep + file
            print("Assembling " + filepath)
            list_file = get_work_file(file.replace(".asm", ".lst"))
            obj_file = get_work_file(file.replace(".asm", ".obj"))
            assemble_command_1 = "xas99.py {source} -S -R -L {list} -o {object} --quiet-unused-syms"
            assemble_command_2 = assemble_command_1.format(source = filepath, list = list_file, object = obj_file)
            os.system(assemble_command_2)

print("Linking 1st Demo Cartridge")
temp_files = [
    "CART",
    "VDP",
    "PIXELROW",
    "PIXELROWCOINC",
    "KEY",
    "MAIN",
    "TILES",
    "FOURPARTTEXT",
    "GROM",
    "FONTS"
]
link_main_files("midFrame." + VERSION + ".C.bin", temp_files)

print("Linking 2nd Demo Cartridge")
temp_files2 = [
    "CARTGAME",
    "PIXELROW",
    "PIXELROWCOINC",
    "VDP",
    "BUTTON",
    "BACKGROUND",
    "SPRITE",
    "MAINGAMELOOP",
    "TILELAYER",
    "SPRITELAYER",
    "STATUSLINE",
    "PLAYER",
    "ENEMY",
    "COLLISION",
    "TUNEBUNY",
    "MUSIC",
    "TONETABLE",
    "DESTROYSOUND",
    "HARMSOUND"
]
link_main_files("parallaxScrolling." + VERSION + ".C.bin", temp_files2)

#Clean up
for file in glob.glob(WORK_FOLDER + "*.lst"):
    os.remove(file)
for file in glob.glob(WORK_FOLDER + "*.obj"):
    os.remove(file)