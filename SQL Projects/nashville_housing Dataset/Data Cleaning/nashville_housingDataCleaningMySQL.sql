# < DATA CLEANING > < NASHVILLE_HOUSING > < MySQL > < ALI SHAHHOUD THE ANALYST >

# => Look At Hole Dataset
select *
from nashville_housing;
# --------------------

# => Create `nashville_housing_cleaned` Table
create table nashville_housing_cleaned
select *,
       row_number() over (
           partition by
               ParcelID,
               LandUse,
               PropertyAddress,
               SaleDate,
               SalePrice,
               LegalReference,
               SoldAsVacant,
               OwnerName,
               OwnerAddress,
               Acreage,
               TaxDistrict,
               LandValue,
               BuildingValue,
               TotalValue,
               YearBuilt,
               Bedrooms,
               FullBath,
               HalfBath
           ) as row_num
from nashville_housing;

select *
from nashville_housing_cleaned;
# --------------------

# => Check Rows Count Between The Tables
select 'nashville_housing' as 'tables', count(*) as 'row_count'
from nashville_housing
union
select 'nashville_housing_cleaned', count(*)
from nashville_housing_cleaned;
# --------------------

# => Check Table Columns Standardization And Consistency
select ID
from nashville_housing_cleaned
order by 1;

select count(distinct ID), count(*)
from nashville_housing_cleaned;

select distinct ParcelID
from nashville_housing_cleaned
order by 1;

select count(distinct ParcelID) as 'distinct_ParcelID_count', count(ParcelID) as 'ParcelID_count'
from nashville_housing_cleaned
order by 1;

select distinct LandUse
from nashville_housing_cleaned
order by 1;
# . . .
# VACANT RES LAND
# VACANT RESIDENTIAL LAND
# VACANT RESIENTIAL LAND
# . . .

# => Standardizing 'LandUse' Column
select LandUse, count(*)
from nashville_housing_cleaned
where LandUse like 'VACANT RES%'
group by LandUse
order by LandUse;
# VACANT RES LAND           1549
# VACANT RESIDENTIAL LAND   3547
# VACANT RESIENTIAL LAND    3

update nashville_housing_cleaned
set LandUse = 'VACANT RESIDENTIAL LAND'
where LandUse like 'VACANT RES%';

update nashville_housing_cleaned
set LandUse = trim(regexp_replace(LandUse, '[[:space:]]+', ' '));
# --------------------

select distinct PropertyAddress
from nashville_housing_cleaned
order by 1;
# "  12TH AVE S, NASHVILLE"
# "  ACKLEN AVE, NASHVILLE"
# "  HADLEYS BEND BLVD, OLD HICKORY"
# "  LONE OAK RD, NASHVILLE"
# "  LOVE JOY CT, NASHVILLE"
# "  MARLBOROUGH AVE, NASHVILLE"
# "  WILD OAKS CT, ANTIOCH"
# . . .

# => Standardizing 'PropertyAddress' Column
update nashville_housing_cleaned
set PropertyAddress = trim(regexp_replace(PropertyAddress, '[[:space:]]+', ' '));
# --------------------

select distinct SaleDate
from nashville_housing_cleaned
order by 1;

# => Convert 'SaleDate' Column From Text Type To Date Type
update nashville_housing_cleaned
set SaleDate = str_to_date(SaleDate, '%M %e, %Y');

alter table nashville_housing_cleaned
    modify column SaleDate date;
# --------------------

select distinct SalePrice
from nashville_housing_cleaned
order by 1;

select distinct SoldAsVacant
from nashville_housing_cleaned
order by 1;
# N
# No
# Y
# Yes

# => Standardizing 'SoldAsVacant' Column
select SoldAsVacant, count(SoldAsVacant)
from nashville_housing_cleaned
group by SoldAsVacant;
# No   51403
# N    399
# Yes  4623
# Y    52

update nashville_housing_cleaned
set SoldAsVacant = case
                       when SoldAsVacant = 'N' then 'No'
                       when SoldAsVacant = 'Y' then 'Yes'
                       else SoldAsVacant
    end;
# --------------------

select distinct OwnerName
from nashville_housing_cleaned
order by 1;

# => Standardizing 'OwnerName' Column
update nashville_housing_cleaned
set OwnerName = trim(regexp_replace(OwnerName, '[[:space:]]+', ' '));
# --------------------

select distinct OwnerAddress
from nashville_housing_cleaned
order by 1;

# => Standardizing 'OwnerAddress' Column
update nashville_housing_cleaned
set OwnerAddress = trim(regexp_replace(OwnerAddress, '[[:space:]]+', ' '));
# --------------------

select distinct Acreage
from nashville_housing_cleaned
order by 1;

# => Standardizing 'Acreage' Column
alter table nashville_housing_cleaned
    modify column Acreage decimal(10, 2);
# --------------------

select distinct TaxDistrict
from nashville_housing_cleaned
order by 1;

select distinct LandValue
from nashville_housing_cleaned
order by 1;

select distinct BuildingValue
from nashville_housing_cleaned
order by 1;

select distinct TotalValue
from nashville_housing_cleaned
order by 1;

select distinct YearBuilt
from nashville_housing_cleaned
order by 1;

select distinct Bedrooms
from nashville_housing_cleaned
order by 1;

select distinct FullBath
from nashville_housing_cleaned
order by 1;

select distinct HalfBath
from nashville_housing_cleaned
order by 1;

select distinct LegalReference
from nashville_housing_cleaned
order by 1;
# -2016598
# -2016946
# -2020316
# -2020879
# -2020988
# -2022158
# . . .

# Invalid Values in 'LegalReference' Field In This Rows So We Will Delete Them
delete
from nashville_housing_cleaned
where length(LegalReference) = 8;
# --------------------
# --------------------

# => Find Duplicated Rows
select *
from nashville_housing_cleaned
where row_num > 1;
# --------------------

# => Delete Duplicate Rows
delete
from nashville_housing_cleaned
where row_num > 1;
# --------------------

# => Populate Null Or Blank Values

# We Note That The Columns Which Contain Null Values At Some Of Their Fields Are :
# [
#   SalePrice,
#   OwnerName,
#   Acreage,
#   TaxDistrict,
#   LandValue,
#   BuildingValue,
#   TotalValue,
#   YearBuilt,
#   Bedrooms,
#   FullBath,
#   HalfBath,
#   PropertyAddress,
#   OwnerAddress,
# ]

# We Will Try To Populate (If It Possible) Null Or Blank Values Depend On The Information In The Same Table
select LandValue + BuildingValue as SumValue, TotalValue
from nashville_housing_cleaned
where LandValue + BuildingValue != TotalValue
  And LandValue is not null
  And LandValue is not null
  And LandValue is not null
order by ID;
# We Have Got 7154 Rows Then TotalValue Not Always Equal LandValue + BuildingValue
# So We Can Not Populate One Of This Three Columns Based On The Other Two Columns
# --------------------

# If There Are Some Rows With Same ParcelID, Logically That's Mean They Must Have At The Very Least Same
# [
#   Acreage,
#   TaxDistrict,
#   YearBuilt,
#   Bedrooms,
#   FullBath,
#   HalfBath,
#   PropertyAddress
# ] Values

select t1.ParcelID, t1.Acreage, t2.ParcelID, t2.Acreage
from nashville_housing_cleaned t1
         inner join nashville_housing_cleaned t2
                    on t1.ParcelID = t2.ParcelID
where t1.Acreage is null
  and t2.Acreage is not null;

select t1.ParcelID, t1.TaxDistrict, t2.ParcelID, t2.TaxDistrict
from nashville_housing_cleaned t1
         inner join nashville_housing_cleaned t2
                    on t1.ParcelID = t2.ParcelID
where t1.TaxDistrict is null
  and t2.TaxDistrict is not null;

select t1.ParcelID, t1.YearBuilt, t2.ParcelID, t2.YearBuilt
from nashville_housing_cleaned t1
         inner join nashville_housing_cleaned t2
                    on t1.ParcelID = t2.ParcelID
where t1.YearBuilt is null
  and t2.YearBuilt is not null;

select t1.ParcelID, t1.Bedrooms, t2.ParcelID, t2.Bedrooms
from nashville_housing_cleaned t1
         inner join nashville_housing_cleaned t2
                    on t1.ParcelID = t2.ParcelID
where t1.Bedrooms is null
  and t2.Bedrooms is not null;

select t1.ParcelID, t1.FullBath, t2.ParcelID, t2.FullBath
from nashville_housing_cleaned t1
         inner join nashville_housing_cleaned t2
                    on t1.ParcelID = t2.ParcelID
where t1.FullBath is null
  and t2.FullBath is not null;

select t1.ParcelID, t1.HalfBath, t2.ParcelID, t2.HalfBath
from nashville_housing_cleaned t1
         inner join nashville_housing_cleaned t2
                    on t1.ParcelID = t2.ParcelID
where t1.HalfBath is null
  and t2.HalfBath is not null;

select t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress
from nashville_housing_cleaned t1
         inner join nashville_housing_cleaned t2
                    on t1.ParcelID = t2.ParcelID
where t1.PropertyAddress is null
  and t2.PropertyAddress is not null;
# We Got 35 Rows

# => Populate Null Values In PropertyAddress Column
update nashville_housing_cleaned t1
    inner join nashville_housing_cleaned t2
    on t1.ParcelID = t2.ParcelID
set t1.PropertyAddress = t2.PropertyAddress
where t1.PropertyAddress is null
  and t2.PropertyAddress is not null;

select *
from nashville_housing_cleaned
where PropertyAddress is null;
# Perfect, Now 'PropertyAddress' Column Doesn't Have Any Null Values
# --------------------
# --------------------
# --------------------

# Check If There Are Rows That Most Of Their Fields Are Null, To Delete Them If They Aren't Useful.

# The Columns Which steel Contains Null Values At Some Of Their Fields Are :
# [
#   SalePrice,
#   OwnerName,
#   Acreage,
#   TaxDistrict,
#   LandValue,
#   BuildingValue,
#   TotalValue,
#   YearBuilt,
#   Bedrooms,
#   FullBath,
#   HalfBath,
#   OwnerAddress,
# ] =>
select *
from nashville_housing_cleaned
where SalePrice is null
  and LandValue is null
  and Acreage is null
  and TaxDistrict is null
  and BuildingValue is null
  and TotalValue is null
  and YearBuilt is null
  and Bedrooms is null
  and FullBath is null
  and HalfBath is null
  and OwnerName is null
  and OwnerAddress is null;
# We Got 6 Rows

# If You Think That This Rows Not Important With All Null Values They Have, You Can Delete Them.
delete
from nashville_housing_cleaned
where SalePrice is null
  and LandValue is null
  and Acreage is null
  and TaxDistrict is null
  and BuildingValue is null
  and TotalValue is null
  and YearBuilt is null
  and Bedrooms is null
  and FullBath is null
  and HalfBath is null
  and OwnerName is null
  and OwnerAddress is null;
# --------------------
# --------------------

# Split Columns With Complex Information If It Possible
# We Note That 'PropertyAddress' And 'OwnerAddress' Columns Contain Information We Can Split Them To Separate Columns, And They Will Become More Understandable.

# => Split 'PropertyAddress' Column To 'SeparatedPropertyAddress' And 'SeparatedPropertyCity' columns
alter table nashville_housing_cleaned
    add column SeparatedPropertyAddress text;

update nashville_housing_cleaned
set SeparatedPropertyAddress = trim(substring_index(PropertyAddress, ',', 1));

alter table nashville_housing_cleaned
    add column SeparatedPropertyCity text;

update nashville_housing_cleaned
set SeparatedPropertyCity = trim(substring_index(PropertyAddress, ',', -1));
# --------------------

# => Check The New Column
select PropertyAddress, SeparatedPropertyAddress, SeparatedPropertyCity
from nashville_housing_cleaned
order by 1;

select count(PropertyAddress), count(SeparatedPropertyAddress), count(SeparatedPropertyCity)
from nashville_housing_cleaned;
# --------------------

# => Split 'OwnerAddress' Column To 'SeparatedOwnerAddress' 'SeparatedOwnerCity' 'SeparatedOwnerState' columns
alter table nashville_housing_cleaned
    add column SeparatedOwnerAddress text;

update nashville_housing_cleaned
set SeparatedOwnerAddress = trim(substring_index(OwnerAddress, ',', 1));

alter table nashville_housing_cleaned
    add column SeparatedOwnerCity text;

update nashville_housing_cleaned
set SeparatedOwnerCity = trim(substring_index(substring_index(OwnerAddress, ',', 2), ',', -1));

alter table nashville_housing_cleaned
    add column SeparatedOwnerState text;

update nashville_housing_cleaned
set SeparatedOwnerState = trim(substring_index(OwnerAddress, ',', -1));
# --------------------

# => Check The New Column
select OwnerAddress, SeparatedOwnerAddress, SeparatedOwnerCity, SeparatedOwnerState
from nashville_housing_cleaned
order by 1;

select count(OwnerAddress), count(SeparatedOwnerAddress), count(SeparatedOwnerCity), count(SeparatedOwnerState)
from nashville_housing_cleaned;
# --------------------
# --------------------

# => Drop Unnecessary Columns

# => Drop 'PropertyAddress' Column Because We Do Not Need It Any More
alter table nashville_housing_cleaned
    drop column PropertyAddress;
# --------------------

# => Drop 'OwnerAddress' Column Because We Do Not Need It Any More
alter table nashville_housing_cleaned
    drop column OwnerAddress;
# --------------------

# => Drop 'row_num' Column Because We Do Not Need It Any More
alter table nashville_housing_cleaned
    drop column row_num;
# --------------------

# Check Only The Columns That Contain Null Values If Most Of Their Values Are Null, Then We Can Delete Them If They Aren't Useful
select count(ID) as total_rows_count, count(ID) - count(SalePrice) as SalePrice_null_count,
       round(((count(ID) - count(SalePrice)) * 100) / count(ID), 2) as SalePrice_null_percentage
from nashville_housing_cleaned;
# 6/56363

select count(ID) as total_rows_count, count(ID) - count(OwnerName) as OwnerName_null_count
from nashville_housing_cleaned;
# 31150/56363

select count(ID) as total_rows_count, count(ID) - count(SeparatedOwnerAddress) as SeparatedOwnerAddress_null_count
from nashville_housing_cleaned;
# 30396/56363

select count(ID) as total_rows_count, count(ID) - count(SeparatedOwnerCity) as SeparatedOwnerCity_null_count
from nashville_housing_cleaned;
# 30396/56363

select count(ID) as total_rows_count, count(ID) - count(SeparatedOwnerState) as SeparatedOwnerState_null_count
from nashville_housing_cleaned;
# 30396/56363

select count(ID) as total_rows_count, count(ID) - count(Acreage) as Acreage_null_count
from nashville_housing_cleaned;
# 30396/56363

select count(ID) as total_rows_count, count(ID) - count(TaxDistrict) as TaxDistrict_null_count
from nashville_housing_cleaned;
# 30396/56363

select count(ID) as total_rows_count, count(ID) - count(LandValue) as LandValue_null_count
from nashville_housing_cleaned;
# 30396/56363

select count(ID) as total_rows_count, count(ID) - count(BuildingValue) as BuildingValue_null_count
from nashville_housing_cleaned;
# 30396/56363

select count(ID) as total_rows_count, count(ID) - count(TotalValue) as TotalValue_null_count
from nashville_housing_cleaned;
# 30396/56363

select count(ID) as total_rows_count, count(ID) - count(YearBuilt) as YearBuilt_null_count
from nashville_housing_cleaned;
# 32247/56363

select count(ID) as total_rows_count, count(ID) - count(Bedrooms) as Bedrooms_null_count
from nashville_housing_cleaned;
# 32253/56363

select count(ID) as total_rows_count, count(ID) - count(FullBath) as FullBath_null_count
from nashville_housing_cleaned;
# 32135/56363

select count(ID) as total_rows_count, count(ID) - count(HalfBath) as HalfBath_null_count
from nashville_housing_cleaned;
# 32266/56363
# --------------------
# --------------------