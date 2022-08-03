import re
import pandas as pd 
import mysql.connector
import os
def check_number(number):
    try:
        int(number)
        return True
    except ValueError:
        return False

def append_in_list(list,number):
    list.append(number)
    return list


def process_data():
    digit_check=""
    string_check=''
    check_all_digit_list=[]
    check_all_string_list=[]
    check_for_pervious=True
    with open("raw_data.txt") as f,open("output.csv","w") as fout:
        for line in f:
            fout.write(line.replace('\t', ','))
                            
def process_sql_file(sql_file,cursor):
    print ("\n[INFO] Executing SQL script file: '%s'" % (sql_file))
    statement = ""

    for line in open(sql_file):
        if re.match(r'--', line):  # ignore sql comment lines
            continue
        if not re.search(r';$', line):  # keep appending lines that don't end in ';'
            statement = statement + line
            print("executing query while you are busy=======>")
            print(line)
        else:  # when you get a line ending in ';' then exec statement and reset for next statement
            statement = statement + line
            #print "\n\n[DEBUG] Executing SQL statement:\n%s" % (statement)
            try:
                cursor.execute(statement)
            except :
                print ("\n[WARN] MySQLError during execute statement \n\tArgs: ")

            statement = ""
def get_files():
    list_of_dirctory=[]
    curent_dir=os.getcwd()
    for file in os.listdir(curent_dir):
        if file.endswith(".sql"):
            # print(os.path.join("/code", file))
            list_of_dirctory.append(file)
    return list_of_dirctory


def main():
    process_data()
    data_frame=pd.read_csv("output.csv",on_bad_lines='skip')
    columns=data_frame.columns
    cnx = mysql.connector.connect(user='root', password='',
                              host='localhost',
                              database='task_inter',port=3306)
    cursor = cnx.cursor()
    
    drop_table="drop table if exists MSTR_Jazz_Real_uploading"
    cursor.execute(drop_table)
    # create_table="create table real_sales(numbering varchar(1000))"
    create_table="create table MSTR_Jazz_Real_uploading({0} varchar(100))"
    add_columns_after="ALTER TABLE MSTR_Jazz_Real_uploading ADD {} varchar(1000)"
    
    check_make_table=True
    for i in columns:
        if check_make_table:
            exe=create_table.format(i)
            cursor.execute(exe)
            
            check_make_table=False
            continue
        add_query=add_columns_after.format(i)
        print(add_query)
        cursor.execute(add_query)    
    try:
        load_data="LOAD DATA  INFILE  'output.csv' INTO TABLE MSTR_Jazz_Real_uploading "
        cursor.execute(load_data)
        print("insert data succefully")
    except:
        print("error while loading data")
    make_it=[]
    check_make_it=[]
    
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%                                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    #############################   Query execution for all raw data   ##########################
    query_data=[]
    with open("1-Input Data Cleaning.sql") as f:
        for i in f:
            if i.startswith('-'):
                print("")
            else:
                try:
                    query_data.append(i)
                    
                except:
                    print("query not run",i)
    
    query_list=[]
    total_counter=0
    total_running=0
    sql_file_name=get_files()
    print("======================")
    print("follwing file are found")
    print(sql_file_name)
    for file in sql_file_name:
        with open(file) as f,open("output_query.txt",'w') as output,open("log_file.txt",'a') as log_file:
            print(file)
            x=f.readlines()
        
            # if x.startswith('S') or x.startswith('s'):
            #      print(x)
            check_str=False
            for i in range(0,len(x)):
                query=''
                if x[i].startswith('-') or x[i].startswith(' '):
                    break
                if x[i].startswith('S') or x[i].startswith('s') or x[i].startswith('u') or x[i].startswith('U') or x[i].startswith('d') or x[i].startswith('D'):
                    if x[i]==' ':
                        continue
                    query=query+''+x[i]
                    
                    for j in range(i+1,len(x)):
                        check=False
                        if x[j].startswith('S') or x[j].startswith('s') or x[j].startswith('u') or x[j].startswith('U') or x[j].startswith('d') or x[j].startswith('D'):
                            
                            check=True
                            break
                        else:
                            if x[j]==' ':
                                continue
                            
                            query=query+''+x[j]
                            check=True
                    query_list.append(query)
                    # if check:
                    #     query=query+';'
            list_query=[]
            total_running=total_running+len(query_list)
            for l in query_list:
                # print(l)
                res = str(re.sub(' +', ' ',l))
                
                yourstring = res.strip('\n\t')
                yourstring = ''.join((yourstring,';'))
                
            
                try:
                    list_query.append(yourstring)
                except:
                    print('error')
            counter=0
            not_run_query=[]
            for k in list_query:
                try:
                    output.write(k+'\n')
                    cursor.execute(k)
                    cursor.fetchall()
                    total_counter+=1
                    # print("executing ===========>")
                    # print(k)
                    counter+=1
                except:
                    not_run_query.append(k)
                    pass
                            #     # try:
                #     if q[1]!='s' or q[1]!='S':
                #         print(q) 
                # except:
                #     print("skipping")    
            # print("total query=======>",len(query_list))
            # print("runn query=========>",counter)
            # print("not run query")
            # print(not_run_query)
            for lb in not_run_query:
                log_file.write(lb)
                log_file.write('\n')
    print(total_running)
    print(total_counter)
if __name__=="__main__":
    main()
    