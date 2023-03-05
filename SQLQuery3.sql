/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format (remove time format and only show the date)

Select saledate, CONVERT(Date,saledate)
From PortfolioProject.dbo.NashvilleHousing

--(Did not work below)
update NashvilleHousing
set saledate=CONVERT(Date,saledate)

--(Try altering)
ALTER TABLE nashvillehousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted=convert(Date,SaleDate);

Select Saledateconverted
From PortfolioProject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

/*there are some null values in the propertyAddress column 
but we can give a value to the PropertyAddress by checking the ParcelId same ParcelID goes with same PrpertyAddress.*/

select PropertyAddress
from NashvilleHousing
where propertyaddress is null;

select parcelid,PropertyAddress,count(parcelid)
from NashvilleHousing
group by parcelid, propertyaddress
having count(parcelid)>1
order by ParcelID;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b on a.parcelid=b.parcelid and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;

Update a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a join NashvilleHousing b on a.parcelid=b.parcelid and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null;




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


--PropertyAddress Breakking using substring

select PropertyAddress
from NashvilleHousing

select SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from NashvilleHousing

ALTER TABLE nashvillehousing
Add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1);

ALTER TABLE nashvillehousing
Add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity=SUBSTRING(PropertyAddress,charindex(',',PropertyAddress)+1, LEN(PropertyAddress))

select *
from NashvilleHousing



--OwnerAddress Breaking using parsename

select owneraddress
from NashvilleHousing;

select PARSENAME(REPLACE(OwnerAddress,',','.'),3), PARSENAME(REPLACE(OwnerAddress,',','.'),2), 
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing;

ALTER TABLE nashvillehousing
Add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE nashvillehousing
Add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE nashvillehousing
Add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1);

select *
from NashvilleHousing







--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

--There are 4 values in SoldAsDistinct column as Yes, No, Y and N; we can replace Y as Yes and N as No

select Distinct(SoldAsVacant)
from NashvilleHousing;

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
end
from NashvilleHousing;

update NashvilleHousing
set SoldAsVacant = 
case when SoldAsVacant='Y' then 'Yes'
	 when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
end

select Distinct(SoldAsVacant)
from NashvilleHousing;




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

select *
from nashvillehousing;

With RowNumCTE As(
select *, ROW_NUMBER() over (Partition by ParcelID,
										  PropertyAddress,
										  SaleDate,
										  SalePrice,
										  LegalReference 
							  order by uniqueId) row_num
from NashvilleHousing
)
Delete
from RowNumCTE
where row_num>1;






---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate








