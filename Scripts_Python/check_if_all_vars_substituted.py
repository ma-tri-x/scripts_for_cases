import os
import sys
import json
import shutil
import re

def load_configuration(filename):
    #return json.load(open("case_conf.json"))
    return json.load(open(filename))

def only_keep_template_paths(l):
    c = []
    for i in l:
        if '.template' in i: c.append(i)
    return c
            
def find_all_variables_in_template(temp):
    p = re.compile('_[A-Z0-9]+[-A-Z0-9_]+')
    matches = []
    with open(temp,'r') as f:
        text = f.readlines()
        for k in text:
            matches.extend(p.findall(k))
    remove_duplicates_from_list(matches)
    return matches

def remove_duplicates_from_list(matches):
    s = set([x for x in matches if matches.count(x) > 1])
    for i in s:
        j = matches.count(i)
        for k in range(j-1):
            matches.remove(i)
            
def compare_found_to_dest(dest, var_list):
    for i in var_list:
        if dest.upper() == i[1:]:
            return i

def replace_found_to_value(var_list, conf_dict):
    for i,placeholder in enumerate(var_list):
        if len(placeholder.split('-')) == 1:
            for first_level_item in conf_dict:
                if first_level_item.upper() == placeholder[1:]:
                    var_list[i] = conf_dict[first_level_item]
        else:
            for first_level_item in conf_dict:
                if first_level_item.upper() == placeholder.split('-')[0][1:]:
                    for second_level_item in conf_dict[first_level_item]:
                        if second_level_item.upper() == placeholder.split('-')[1]:
                            var_list[i] = conf_dict[first_level_item][second_level_item]
                            
def find_and_replace_variables_in_copied_templates(tree_less, conf_dict):
    for copied_template in tree_less:
        the_vars = find_all_variables_in_template(copied_template)
        #print the_vars 
        transl_vars = list(the_vars)
        replace_found_to_value(transl_vars, conf_dict)
        #print transl_vars 
        with open(copied_template, 'r') as f:
            content = f.read()
        for i,var in enumerate(the_vars):
            if transl_vars[i] is not None: content = content.replace(var, str(transl_vars[i]))
        with open(copied_template, 'w') as f:
            f.write(content)

def main():
    conf_dict = load_configuration("conf_dict.json")
    
    tree1 = only_keep_template_paths(os.listdir('.'))
    tree2 = only_keep_template_paths(os.listdir('./constant'))
    tree2 = ['./constant/{}'.format(i) for i in tree2]
    tree3 = only_keep_template_paths(os.listdir('./constant/polyMesh'))
    tree3 = ['./constant/polyMesh/{}'.format(i) for i in tree3]
    tree4 = only_keep_template_paths(os.listdir('./system'))
    tree4 = ['./system/{}'.format(i) for i in tree4]
    tree5 = only_keep_template_paths(os.listdir('./0'))
    tree5 = ['./0/{}'.format(i) for i in tree5]
    tree = tree1
    tree.extend(tree2)
    tree.extend(tree3)
    tree.extend(tree4)
    tree.extend(tree5)
    
    tree_less = []
    for i in tree: tree_less.append(i.split('.template')[0])
    
    for i in tree_less:
        print i
        print find_all_variables_in_template(i)
    
if __name__ == '__main__':
    main()