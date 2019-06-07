import matplotlib.pyplot as plt
import pandas as pd

df = pd.read_csv(r'F:\Documents\University\Math Project\Project Year 4\Machine Learning\Job Example\Task Sheet\Postcode_Estimates_Table_1.csv') # Create dataframe
print('Original Data')
print()
print(df.head())
print()

clist = list(df['Postcode'])
clist = [i[:3] for i in clist] # Reduce Postcode to the first 3 characters
del df['Postcode']
df.insert(0, 'Postcode', clist) # Replace old Postcode column with new column
print('Reduced Postcode Data')
print()
print(df.head())
print(df.shape)
print()

df = df.groupby('Postcode')['Total', 'Males', 'Females', 'Occupied_Households'].sum().reset_index() # Group together rows with the same postcode
print('Grouped Postcode Data')
print()
print(df.head())
print(df.shape)
print()
max = len(df)

n = 20000      # This number is set so that we group together all the postcodes where the the total is less than n
multiplier = 2.5 # This number controls the max value that Total Addition can sum up to (1 for 20,000 gives issue in report, 2.5 for 50,000 to solves issue)

dfSmall = df[df['Total'] <= n].reset_index(drop=True) # Create new dataframe with all the postcodes where Total <= n
df = df[df['Total']>n].reset_index(drop=True)         # Overwrite original dataframe to now only consist of postcodes with more than 20,000 residents
print('Grouped Data where Total <',n)
print()
print(dfSmall.head())
print(dfSmall.shape)
min = len(dfSmall)
print()

print('The percentage of postcodes less than', n, 'is: {:.1%}'.format((min/max)))
print()

dfSmall = dfSmall.sort_values(by=['Total']) # Set the dataframe to decend from the lowest value of Total
dfSmall = dfSmall.reset_index()
dfSmall['Total Addition'] = dfSmall['Total'].cumsum() # Create new column that is the sum of the column Total
print('Ordered Grouped Data')
print(dfSmall.head())
print()
cond = dfSmall[dfSmall['Total Addition']<=n*multiplier] # The first n rows where Total Addition < n*multiplier
index = dfSmall.index.get_loc(cond.iloc[-1].name) + 1   # Capture the highest index and add 1 which is the total number of rows
print('The first',index,'rows where Total Addition <',n*multiplier)
print()
print(cond)
print()
l = 5 # Total number of columns to be created
lists = [[] for _ in range(l)]

t = True
while t:            
    lists[0] += [dfSmall[0:index]['Postcode'].sum()]            # This is the main piece of code that calculates the groups of postcodes to be re-labeled
    lists[1] += [dfSmall[0:index]['Total'].sum()]               # to the new codes. It sums all columns for the total number of rows less than cond and
    lists[2] += [dfSmall[0:index]['Males'].sum()]               # stores the values in individual lists,
    lists[3] += [dfSmall[0:index]['Females'].sum()]             
    lists[4] += [dfSmall[0:index]['Occupied_Households'].sum()] 
    dfSmall = dfSmall.iloc[index:]                              # removes these rows and resets the index values
    dfSmall = dfSmall.reset_index(drop=True)
    del dfSmall['Total Addition']                               # resets the Total addition column and repeats the process until all rows have been accounted for
    dfSmall.insert(6, 'Total Addition', dfSmall['Total'].cumsum())
    cond = dfSmall[dfSmall['Total Addition']<=n*multiplier]
    if len(dfSmall.index) == 0:
        break
    #print(cond)
    index = dfSmall.index.get_loc(cond.iloc[-1].name) + 1

frames = list(zip(lists[0],lists[1],lists[2],lists[3],lists[4])) # Creates the new dataframe using all the lists made in the loop
frames = pd.DataFrame(frames, columns=['Postcode', 'Total', 'Males', 'Females', 'Occupied_Households'])

list = frames['Postcode'] # Stores values of the groups of original postcodes and then deletes that column to replace with the new codes 001, 002, etc
del frames['Postcode']
code = [str(x).zfill(3) for x in range(len(frames))]
frames.insert(0, 'Postcode', code)
frames.insert(5, 'Original Postcodes', list) # then inserts the groups of original postcodes as the final column
print('Sorted Total Data for Frames Dataframe')
print()
print(frames.sort_values(by=['Total']).head())
print()

pd.set_option('display.max_columns', None)
df['Original Postcodes'] = ['' for _ in range(0, len(df))] # To prevent NaN values coming up in the Original Postcodes column
combine = [frames, df]
combine = pd.concat(combine, sort=False) # Combine the new code groups and the rest of the postcodes greater than n into one dataframe.
print('The First 5 Rows of the Final Dataframe')
print()
print(combine.head())                    # View the final results
print() 
print('The Last 5 Rows of the Final Dataframe')
print(combine.tail())

#plt.bar(combine['Postcode'], combine['Total']) # To view the bar charts of the final dataframe but takes a lot of processing power
#plt.xticks(rotation='vertical')
#plt.show()
