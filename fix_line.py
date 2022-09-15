def replace_line(file_name, line_num, text):
    lines = open(file_name, 'r').readlines()
    lines[line_num] = text
    out = open(file_name, 'w')
    out.writelines(lines)
    out.close()

def replace_line_in_file(file_name, line_to_search, text_to_replace):
    with open(file_name, 'r') as file:
        # read a list of lines into data
        data = file.readlines()

    for line in data:
        # if the line contains the string we're looking for,
        # write the line to the output file
        if line_to_search in line:
            replace_line(file_name, data.index(line), text_to_replace)

replace_line_in_file('/content/stable-diffusion-webui/webui.py', 'pl_sd = torch.load(ckpt, map_location="cpu")', '    pl_sd = torch.load(ckpt, map_location="cuda:0")\n')
