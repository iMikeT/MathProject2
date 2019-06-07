import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import random
from scipy import stats

np.random.seed(100) # For consistent testing
# The arbitrary levels
data = ['a', 'b', 'c']
rows = 50000
cols = 8
# Create data frame
df = pd.DataFrame(np.random.choice(data, size=(rows, cols)), columns = list('STUVWXYZ')) # a) Each element is a random choice of the list data, specifying the shape
                                                                                         # and setting each column name as a different arbirtary name. Uniform
                                                                                         # random sample
print('Data Frame')
print(df.head()) # Show the first 5 rows of the data frame
print()

# b) Calculate frequency of category levels in each column
print('Frequency Table to Compare Proportions')
print(df.apply(pd.value_counts).T)
print()
# Visual representation using bar chart
plt.show(df.apply(pd.value_counts).T.plot(kind='bar', rot=0))

# c) 3 letters to choose from and we chose 8, 1 for each column. So number of permutations is 3^8
print('\nThe number of unique rows is: 3^8 = ', 3**8)

# A way to calculate the number of unique rows in the data frame
# print(rows - (len(df)-len(df.drop_duplicates())))

freq = df.groupby(list('STUVWXYZ')).size().to_frame('count').reset_index() # Frequency of all unique permutations in dataframe df
print(freq)

# d) Calculate the number of rows for group size 1 to 10. There are no unique rows. Every possible permutation (3^8) occur more than once
g = np.zeros(10, dtype = int)
for i in range(1,11):
    g[i-1] = len(freq[freq['count'] == i])*i

freq = pd.DataFrame(data = {'Group Size': [n for n in range(1,11)], 'No of rows': g})
print(freq)
print()
plt.show(plt.bar(freq['Group Size'], freq['No of rows']))

# e) The number of rows is a left skew distribution. If we were to continue with a larger number of group size then the distribution would be normally distributed centered at the group size equal to the number of columns 8.

# f) Missing data would complicate part d) because there would be know group size that this missing data could fall into. For this code, if there was a frequency count of the missing data say == 3, then that would result in extra counts being added to group size 3 even though the missing data might not have actually been in that group. This produces miscounts
