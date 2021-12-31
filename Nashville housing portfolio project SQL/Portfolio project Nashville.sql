--Cleaning data

Select * from NashvilleHousing

--Date format
select SaleDate,CONVERT(date,SaleDate) from NashvilleHousing

--Add new column with converted sales date
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate)

select SaleDateConverted from NashvilleHousing


--Populate property address data
--Get rows with null PropertyAddress
select PropertyAddress from NashvilleHousing
where PropertyAddress is null

select * from NashvilleHousing
order by ParcelID

-- Join the database with the same database using parcel ID and different Unique ID
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b on
a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null
--take property address from different field which has unique id and same parcel ID
update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b on
a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]


--Breaking down addresses into address, city, state
select PropertyAddress
from NashvilleHousing

select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress)) 
from NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+2,LEN(PropertyAddress)) 

select PropertySplitAddress, PropertySplitCity from NashvilleHousing

select OwnerAddress from NashvilleHousing

select PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from NashvilleHousing


--Add separate columns for Address, City, State from OwnerAddress
Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState from NashvilleHousing


--Change Y and N in 'Sold as Vacant' to Yes and No

select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant ,
CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousing

Update NashvilleHousing
set SoldAsVacant =
CASE when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

--Handle Duplicates
with RowNumCTE as(
select * ,
ROW_NUMBER() Over (
Partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference Order by UniqueID) row_num
from NashvilleHousing)
select * from RowNumCTE
where row_num > 1


--Delete unused columns
select * from NashvilleHousing

Alter Table NashvilleHousing 
Drop Column OwnerAddress, PropertyAddress, SaleDate, TaxDistrict