/* 

Data Cleaning in SQL Queries 

*/

Select * from PortfolioProject..NashvilleHousing

-- Standardize Date Format, changing data type of SaleDate column from datetime data type to date data type.

alter table [NashvilleHousing]
alter column [SaleDate] Date

-- Populate Property Address Data

Select * from PortfolioProject..NashvilleHousing 
where PropertyAddress is null order by ParcelID

Select a1.ParcelID, a1.PropertyAddress, a2.ParcelID, a2.PropertyAddress, isnull (a1.PropertyAddress, a2.PropertyAddress)
from PortfolioProject..NashvilleHousing a1
join PortfolioProject..NashvilleHousing a2
on a1.ParcelID = a2.ParcelID
and a1.[UniqueID ] != a2.[UniqueID ]
where a1.PropertyAddress is null

update a1
set PropertyAddress = isnull (a1.PropertyAddress, a2.PropertyAddress)
from PortfolioProject..NashvilleHousing a1
join PortfolioProject..NashvilleHousing a2
on a1.ParcelID = a2.ParcelID
and a1.[UniqueID ] != a2.[UniqueID ]
where a1.PropertyAddress is null


------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out PropertyAddress into individual columns(Address, city, state)

Select PropertyAddress from PortfolioProject..NashvilleHousing order by ParcelID

select SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) as address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as CityAddress
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertyCityAddress nvarchar(255);

update PortfolioProject..NashvilleHousing
set PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

update PortfolioProject..NashvilleHousing
set PropertyAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1)

select * from PortfolioProject..NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------------------------
--Breaking out OwnerAddress into individual columns(Address, city, state)


select OwnerAddress, PARSENAME (REPLACE(OwnerAddress,',','.'), 3) as OwnerAddress,
PARSENAME (REPLACE(OwnerAddress,',','.'), 2) as OwnerCity,
PARSENAME (REPLACE(OwnerAddress,',','.'), 1) as OwnerState
from PortfolioProject..NashvilleHousing where OwnerAddress is not null

alter table PortfolioProject..NashvilleHousing
add OwnerCity nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerCity = PARSENAME (REPLACE(OwnerAddress,',','.'), 2)

alter table PortfolioProject..NashvilleHousing
add OwnerState nvarchar(255);

update PortfolioProject..NashvilleHousing
set OwnerState = PARSENAME (REPLACE(OwnerAddress,',','.'), 1)

update PortfolioProject..NashvilleHousing
set OwnerAddress = PARSENAME (REPLACE(OwnerAddress,',','.'), 3)

select * from PortfolioProject..NashvilleHousing where OwnerAddress is not null


------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in SoldAsVacant column

select distinct SoldAsVacant, count(SoldAsVacant)
from PortfolioProject..NashvilleHousing 
where OwnerAddress is not null group by SoldAsVacant order by 2

select SoldAsVacant, Case when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' then 'No' else SoldAsVacant end
from PortfolioProject..NashvilleHousing 

Update PortfolioProject..NashvilleHousing 
set SoldAsVacant = Case when SoldAsVacant = 'Y' Then 'Yes'
when SoldAsVacant = 'N' then 'No' else SoldAsVacant end


---------------------------------------------------------------------------------------------------------------------------------------------
--  


with rownumcte as (
select *, ROW_NUMBER() over( PARTITION BY ParcelID, propertyaddress, propertycityaddress, 
saleprice, saledate, legalreference order by uniqueid) as row_num
from PortfolioProject..NashvilleHousing 
--order by ParcelID
)

select * from rownumcte
where row_num > 1


-----------------------------------------------------------------------------------------------------------------------------------------------
-- Delete unused Columns 

select * from PortfolioProject..NashvilleHousing 

Alter table PortfolioProject..NashvilleHousing 
DROP column TaxDistrict 