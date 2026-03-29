import pandas as pd
import matplotlib.pyplot as plt
import matplotlib as mpl
import numpy as np


df = pd.read_csv('bmw.csv')

# clean column names
df.columns = df.columns.str.lower().str.strip()

# remove unwanted columns

df = df.drop(columns=[
    'unnamed: 12',
    'unnamed: 13',
    'unnamed: 14',
    'unnamed: 15',
    'unnamed: 16'
])

df.info()


df.select_dtypes(include=['object', 'string']).apply(lambda x: x.str.strip())
# create a function for them all


def clean_ints(cols):
    df[cols] = df[cols].str.replace('.00', '').str.replace(
        '$', '').str.replace(',', '')
    df[cols] = df[cols].astype(int)

    return df.head(2)


clean_ints('revenue')
clean_ints('price_usd')
clean_ints('mileage_km')

chart_color = '#0543a6'

Total_revenue = df['revenue'].sum()
print(f'Total Revenue: {Total_revenue:,.2f} \n Nineteen trillion, twelve billion, two hundred forty-two million, five hundred thirty-four thousand, four hundred fifty-nine.\n')

# Total Sales
Total_sales = df['sales_volume'].sum()
print(f' Total Sales: {Total_sales:,.2f} \n Two hundred fifty-three million, three hundred seventy-five thousand, seven hundred thirty-four.')

sales_grp = df.groupby('model')['sales_volume'].sum(
).reset_index().sort_values(by='sales_volume', ascending=False)
sales_grp

revenue_grp = df.groupby('model')['revenue'].sum(
).reset_index().sort_values(by='revenue', ascending=False)
# revenue_grp['revenue'].apply(lambda x: f'{x:,.2f}')
revenue_grp

fig, ax = plt.subplots(1, 2, figsize=(12, 4))
fig.suptitle("Revenue and Sales By Models", fontweight='bold')

ax[0].bar(revenue_grp['model'], revenue_grp['revenue'])
ax[0].set_title("Revenue by Models")
ax[0].set_ylabel("Revenue (x 1,000,000,000)", labelpad=10)
ax[0].tick_params(axis='x', rotation=25)
ax[0].set_xlabel("Models", labelpad=10, fontweight='bold')
ax[1].bar(sales_grp['model'], sales_grp['sales_volume'])
ax[1].set_title('Sales Volume by Models')
ax[1].tick_params(axis='x', rotation=15)
ax[1].set_xlabel("Models", labelpad=10, fontweight='bold')
ax[1].set_ylabel("Sales Volume (x 10,000,000)", labelpad=10)
fig.tight_layout()

# AVERAGE PRICE PER MODEL

model_price = df.groupby('model')['price_usd'].mean(
).reset_index().sort_values(by='price_usd', ascending=False)


plt.bar(model_price['model'], model_price['price_usd'])
plt.xticks(rotation=15)
plt.figure(figsize=(10, 4))
plt.tight_layout()
plt.show()

yearly_trends = df.groupby('year')[['revenue', 'sales_volume']].sum(
).sort_values(by='revenue', ascending=False).reset_index()
yearly_trends['year'].astype(str)
yearly_trends

yearly_trends = yearly_trends.sort_values(by='year')
fig, ax = plt.subplots(1, 2, figsize=(16, 4))
plt.suptitle('Sales and Revenue By years', fontweight='bold', y=1.02)

ax[1].plot(yearly_trends['year'], yearly_trends['revenue'],
           marker='o',
           linestyle='-',
           color=chart_color)

ax[0].plot(yearly_trends['year'], yearly_trends['sales_volume'],
           marker='o',
           linestyle='-',
           color=chart_color)
ax[1].set_title('Revenue Trend Through The Years', fontname='arial')
ax[0].set_title('Sales Trend Through The Years', fontname='arial')


ax[0].set_ylabel("Sales Volume (x10,000,000)", labelpad=15, fontweight='bold')
ax[1].set_ylabel("Revenue (x10,000,000)", labelpad=15, fontweight='bold')

for chart in ax:
    chart.spines[['top', 'right']].set_visible(False)
    chart.grid(True, linestyle='--', alpha=0.5)
    chart.set_xlabel("Years", labelpad=15, fontweight='bold')
    chart.set_xlabel("Years", labelpad=15, fontweight='bold')

plt.show()

percentage_revenue_change = round(
    (100 * (yearly_trends.iloc[-1]['revenue'] - yearly_trends.loc[0, 'revenue'])) / yearly_trends.loc[0, 'revenue'], 0)

print(
    f'Percentage difference between 2010 revenue and 2024 Revenue: {percentage_revenue_change}%')

yearly_trends['year'] = yearly_trends['year'].astype(int)
yearly_trends = yearly_trends.reset_index(drop=True)
yearly_trends['prev_yr_rev'] = yearly_trends['revenue'].shift(1)
yearly_trends = yearly_trends.fillna('0')
yearly_trends['prev_yr_rev'] = yearly_trends['prev_yr_rev'].astype(int)
yearly_trends['rev_growth'] = yearly_trends['revenue'] - \
    yearly_trends['prev_yr_rev']
yearly_trends.loc[0, 'rev_growth'] = 0
yearly_trends['(%) Growth'] = round(
    (100 * yearly_trends['rev_growth']) / yearly_trends['prev_yr_rev'], 2)

yearly_trends

avg_growth = round(yearly_trends['(%) Growth'].mean(), 2)

print(f'Average growth all time: {avg_growth}%')

plt.bar(yearly_trends['year'], yearly_trends['(%) Growth'], color=chart_color)
plt.title("Year On Year Growth On Revenue",
          fontweight='bold',
          pad=5,
          fontname='Arial')
plt.xlabel('Years', fontweight='bold')
plt.ylabel('Percentage Revenue growth')
plt.tight_layout()
plt.show()


yearly_trends['prev_yr_sales'] = yearly_trends['sales_volume'].shift(1)
yearly_trends['prev_yr_sales'] = yearly_trends['prev_yr_sales'].fillna(0)

yearly_trends['prev_yr_sales'] = yearly_trends['prev_yr_sales'].astype(int)
yearly_trends['sales_growth'] = yearly_trends['sales_volume'] - \
    yearly_trends['prev_yr_sales']
yearly_trends.loc[0, 'sales_growth'] = 0
yearly_trends['pcnt Growth'] = round(
    (100 * yearly_trends['sales_growth']) / yearly_trends['prev_yr_sales'], 2)


plt.bar(yearly_trends['year'], yearly_trends['pcnt Growth'], color=chart_color)
plt.title("Year On Year Growth On Sales",
          fontweight='bold',
          pad=5,
          fontname='Arial')
plt.xlabel('Years', fontweight='bold')
plt.ylabel('Percentage Sales growth')
plt.tight_layout()
plt.show()

region_data = df.groupby(
    'region')[['revenue', 'sales_volume']].sum().reset_index()
region_data

fig, ax = plt.subplots(1, 2, figsize=(16, 6))

region_data.sort_values(by='sales_volume', inplace=True)
ax[0].barh(region_data['region'],
           region_data['sales_volume'], color=chart_color)
region_data.sort_values(by='revenue', inplace=True)
ax[1].barh(region_data['region'], region_data['revenue'], color='#070c4d')
ax[1].set_title('Revenue By Regions')
ax[0].set_title('Sales By Regions')
ax[0].set_xlabel('Sales Volume (x10,000,000)', fontweight='bold', labelpad=10)
ax[1].set_xlabel('Revenue (x1,000,000,000,000)',
                 fontweight='bold', labelpad=10)


plt.tight_layout()
plt.show()


region_data['total_revenue'] = region_data['revenue'].sum()
region_data['total_sales'] = region_data['sales_volume'].sum()


region_data['percent_sales_contr'] = round(
    (100 * region_data['sales_volume'] / region_data['total_sales']), 2)
region_data['percent_revenue_contr'] = round(
    (100 * region_data['revenue'] / region_data['total_revenue']), 2)


fig, ax = plt.subplots(1, 2, figsize=(12, 6))

ax[1].pie(region_data['percent_revenue_contr'],
          autopct='%.2f%%', labels=region_data['region'],
          explode=[0.01, 0.01, 0.01, 0.01, 0.01, 0.1],
          colors=["#2e3bf1", "#0f1bc5"])

ax[0].pie(region_data['percent_sales_contr'],
          autopct='%.2f%%', labels=region_data['region'],
          explode=[0.01, 0.01, 0.01, 0.01, 0.01, 0.1],
          colors=["#045e2b", "#033a1b"])


for chart in ax:
    for text in chart.texts:
        if '%' in text.get_text():
            text.set_color('white')
            text.set_fontweight('bold')


ax[1].set_title('Percentage Revenue Contribution per Region',
                fontweight='bold')
ax[0].set_title('Percentage Sales Contribution per Region', fontweight='bold')
plt.tight_layout()
plt.show()


regions_years = df.groupby(['year', 'region'])['revenue'].sum(
).reset_index().sort_values(by=['region', 'region'])

regions_years.reset_index(drop=True, inplace=True)


regions_years['previous_year'] = regions_years.groupby('region')[
    'revenue'].shift(1)
regions_years = regions_years.dropna()
regions_years['previous_year'] = regions_years['previous_year'].astype('Int64')
regions_years['growth_volume'] = regions_years['revenue'] - \
    regions_years['previous_year']
regions_years['percent_growth'] = round(
    (100 * regions_years['growth_volume']) / regions_years['previous_year'], 2)


fig, ax = plt.subplots(2, 3, figsize=(18, 8))
plt.subplots_adjust(hspace=0.3)

plt.suptitle("Year On Year Growth across Regions",
             fontname='arial', fontweight='bold', fontsize=20)
ax[0, 0].bar(regions_years[0:14]['year'], regions_years[0:14]
             ['percent_growth'], color='#4CAF50')
ax[0, 0].set_title("YoY Growth: Africa")

ax[0, 1].bar(regions_years[14:29]['year'], regions_years[14:29]
             ['percent_growth'], color='#F44336')
ax[0, 1].set_title("YoY Growth: Asia")

ax[0, 2].bar(regions_years[29:44]['year'], regions_years[29:44]
             ['percent_growth'], color='#2196F3')
ax[0, 2].set_title("YoY Growth: Europe")

ax[1, 0].bar(regions_years[44:59]['year'], regions_years[44:59]
             ['percent_growth'], color='#FF9800')
ax[1, 0].set_title("YoY Growth: Middle East")

ax[1, 1].bar(regions_years[59:74]['year'], regions_years[59:74]
             ['percent_growth'], color='#0D47A1')
ax[1, 1].set_title("YoY Growth: North America")

ax[1, 2].bar(regions_years[74:89]['year'], regions_years[74:89]
             ['percent_growth'], color="#968704")
ax[1, 2].set_title("YoY Growth: South America")


plt.show()

a = regions_years[0:14]['percent_growth'].mean()
asia = regions_years[14:29]['percent_growth'].mean()
europe = regions_years[29:44]['percent_growth'].mean()
mid_east = regions_years[44:59]['percent_growth'].mean()
s_am = regions_years[59:74]['percent_growth'].mean()
n_am = regions_years[74:89]['percent_growth'].mean()

avg_reg_gr = pd.DataFrame({
    'regions': ['Africa', 'Asia', 'Europe', 'mid_east', 'South America', 'North America'],
    "avg_growth": [a, asia, europe, mid_east, s_am, n_am]
})

avg_reg_gr = avg_reg_gr.sort_values(by='avg_growth', ascending=True)


# calculate percentage revenue increment from 2010 to 2024

rev_change = (df.groupby(['region', 'year'])[
              'revenue'].sum().unstack(fill_value=0))
rev_change = rev_change.rename(
    columns={2010: 'First_year_revenue', 2024: 'Final_Year_revenue'})
rev_change = rev_change.reset_index()


rev_change['revenue_change'] = (
    rev_change['Final_Year_revenue'] - rev_change['First_year_revenue'])

rev_change['percent_growth'] = (
    (100 * rev_change['revenue_change']) / rev_change['First_year_revenue']).round(2)


rev_change = rev_change.sort_values(by='percent_growth', ascending=True)


# plot for the two revenue growth calculations
fig, ax = plt.subplots(1, 2, figsize=(12, 4))

ax[0].barh(avg_reg_gr['regions'], avg_reg_gr['avg_growth'], color='#0D47A1')
ax[0].set_title(
    "Average Percentage Revenue Growth Across the Years.", fontname='Arial', pad=15)

ax[0].set_xlabel('(%)')
ax[1].barh(rev_change['region'], rev_change['percent_growth'], color='#0D47A1')
ax[1].set_title(
    "Percentage Difference Between 2010 Revenue and 2024 Revenue", fontname='arial', pad=15)
ax[1].set_xlabel('(%)')

plt.tight_layout()

plt.show()

# Average Price of cars across regions

prices_per_model = df.groupby('region')['price_usd'].agg([
    'mean',
    'median'
]).round(2).reset_index().sort_values(by='mean', ascending=False)


prices_per_model.set_index('region')['mean'].plot(
    kind='bar', color=chart_color, figsize=(6, 4))
plt.title('Average Price of  Cars across Regions')
plt.ylabel('Average Price', labelpad=15)
plt.xlabel('Region')
plt.show()


model_region_pivot = df.pivot_table(
    columns='model', index='region', values='sales_volume', aggfunc='sum')


model_region_pivot


# Vehicle Perfomance (sales) by Regions

ax = model_region_pivot.plot(
    kind='bar',
    figsize=(16, 6),
    width=0.8,
    color=(
        "#1B3B5F",  "#D1495B",   "#007F5F", "#FF8C00",   "#6A0572",  "#9A031E",
        "#2E4057", "#F77F00", "#0B3C5D", "#3F681C",  "#5C4033")
)

plt.ylabel("Sales (x1,000,000)", labelpad=10, fontweight='bold')
plt.xlabel("Regions", labelpad=10, fontweight='bold')
ax.legend(title='Model', bbox_to_anchor=(1, 1), loc='upper left')
plt.xticks(rotation=45, ha='right')
plt.title('Model Perfomance (sales) Across the Regions',
          fontsize=20, fontname='arial')


# plt.tight_layout()

plt.show()


fuel_type = df.groupby('fuel_type')[
    ['sales_volume', 'revenue']].sum().reset_index()
fuel_type


fig, ax = plt.subplots(1, 2, figsize=(14, 4))
plt.suptitle("Revenue and Sales According Fuel Type", y=1, fontweight='bold')

fuel_type = fuel_type.sort_values(by='sales_volume', ascending=False)
ax[0].bar(fuel_type['fuel_type'], fuel_type['sales_volume'], color="#1111A8F8")
ax[0].set_title('Revenue By Fuel Types')
ax[0].set_ylabel('Revenue (x 10,000,000)')


fuel_type = fuel_type.sort_values(by='revenue', ascending=False)
ax[1].bar(fuel_type['fuel_type'], fuel_type['revenue'], color="#1C1FC7")
ax[1].set_title('Sales By Fuel Types')
ax[1].set_ylabel('Revenue (x 1,000,000,000,000)')

plt.show()


fuel_pivot = df.pivot_table(
    columns='fuel_type', values='sales_volume', aggfunc='sum', index='region').reset_index()
fuel_pivot


ax = fuel_pivot.set_index('region').plot(kind='bar', figsize=(
    10, 5), width=0.8, color=("#1f77b4", "#2ca02c",  "#ff7f0e", "#d62728"))

ax.legend(title='Fuel Type', bbox_to_anchor=(1, 1), loc='upper left')
plt.title("Fuel Type Purchase Across Regions")
plt.tight_layout()
plt.show()

# Group by regions
txns_pivot = df.pivot_table(columns='transmission', values='sales_volume',
                            aggfunc='sum', index='region').reset_index()
txns_pivot


ax = txns_pivot.set_index('region').plot(
    kind='bar', figsize=(10, 5), color=["#5050C1", '#111199'])

ax.legend(title='Fuel Type', bbox_to_anchor=(1, 1), loc='upper left')
plt.title('Transmission  preference by regions')

plt.show()

# create a Bucket for the engine sizes

df['engine_groups'] = pd.cut(
    df['engine_size_l'],
    bins=[0, 1.9, 2.9, 3.9, 4.9, 5],
    labels=[
        '1.0 - 1.9L',
        '2.0 - 2.9L',
        '3.0 - 3.9L',
        '4.0 - 4.9L',
        '5L above'
    ]
)


engine_grps = df.groupby(['engine_groups'])[
    ['sales_volume', 'revenue']].sum().reset_index()
engine_grps = engine_grps.sort_values(by='sales_volume', ascending=False)
engine_grps


engine_grps = df.groupby(['engine_groups'])[
    ['sales_volume', 'revenue']].sum().reset_index()
engine_grps = engine_grps.sort_values(by='sales_volume', ascending=False)
engine_grps


ax = engine_grps_regions.set_index('region').plot(
    kind='bar'
)

ax.legend(title='Fuel Type', bbox_to_anchor=(1, 1), loc='upper left')

plt.title('Engine Size  preference by regions')
plt.Figure(figsize=(8, 4))

plt.show()


# Create Bins for the mileage groups

df['mileage_km_grps'] = pd.cut(
    df['mileage_km'],
    bins=[0, 50000, 100000, 900000],
    labels=[
        'Low Mileage(≤ 50,000km)',
        'medium Mileage(50,001 - 100,000 km)',
        'High Mileage(100,000 km +)'
    ]
)


miles_price = df.groupby('mileage_km_grps').agg(
    Avg_Price=('price_usd', 'median'),
    Sales=('sales_volume', 'sum')
).reset_index()

miles_price['Avg_Price'] = miles_price['Avg_Price'].round(2)

miles_price

# sort
miles_price_sorted = miles_price.sort_values(by='Sales', ascending=False)


normal = mpl.colors.Normalize(
    vmin=miles_price_sorted['Avg_Price'].min(),
    vmax=miles_price_sorted['Avg_Price'].max()
)

colormap = mpl.cm.coolwarm
colors = cmap(norm(miles_price_sorted['Avg_Price']))


fig, ax = plt.subplots(figsize=(12, 6))


ax.bar(
    miles_price_sorted['mileage_km_grps'],
    miles_price_sorted['Sales'], color=colors)

ax.set_xlabel('Mileage Groups')
ax.set_ylabel('Total Sales')
ax.set_title('Sales by Mileage Group (Color-coded by Average Price)')


sm = mpl.cm.ScalarMappable(cmap=colormap, norm=normal)
sm.set_array([])

cbar = fig.colorbar(sm, ax=ax)
cbar.set_label('Average Price (USD)')

plt.tight_layout()
plt.show()
