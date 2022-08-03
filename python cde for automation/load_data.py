from operator import index
import pandas as pd 
data_set=pd.read_csv("sample data June 22.csv",lineterminator='\n')
# # print(data_set)
# # print(len(data_set.columns))
new_data_set=data_set[["Sub","Channel","ondate"]]
new_data_set.set_index("Sub")
print(new_data_set)
new_data_set.to_csv('sample data june 22.csv')
test_data=pd.read_csv("sample data june 22.csv")
print(test_data)
with open("sample data June 22.csv") as f:
    read_data=f.read()
    print(read_data)

    