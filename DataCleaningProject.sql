SELECT * from NACHVILLE

-- standardize date format

select NACHVILLE.SaleDate , CONVERT(date,NACHVILLE.SaleDate)as SaleDate
from NACHVILLE 

Alter table NACHVILLE
ADD SaleDateConverted date;

update NACHVILLE
set SaleDateConverted = CONVERT(date, SaleDate)

--Populaire property adress

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from NACHVILLE a
join NACHVILLE b
on  a.ParcelID = b.ParcelID
where a.PropertyAddress is null 

update a
set 
PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NACHVILLE a
join NACHVILLE b
on  a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- breaking out address into (address,city,state)

select NACHVILLE.PropertyAddress, SUBSTRING( PropertyAddress ,1,CHARINDEX(',',PropertyAddress)-1) as Address1 ,SUBSTRING( PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address2
from NACHVILLE 

alter table NACHVILLE 
add PropertySplitAddress nvarchar(255);

update NACHVILLE
set  PropertySplitAddress =SUBSTRING( PropertyAddress ,1,CHARINDEX(',',PropertyAddress)-1)

alter table NACHVILLE
ADD PropertySplitCity nvarchar(255);

update NACHVILLE
set PropertySplitCity=SUBSTRING( PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


select PARSENAME(replace(OwnerAddress,',','.'),3),PARSENAME(replace(OwnerAddress,',','.'),2),PARSENAME(replace(OwnerAddress,',','.'),1)
from NACHVILLE

alter table NACHVILLE 
add OwnerSplitAddress nvarchar(255);

update NACHVILLE
set  OwnerSplitAddress =PARSENAME(replace(OwnerAddress,',','.'),3)

alter table NACHVILLE 
add OwnerSplitAddressCity nvarchar(255);

update NACHVILLE
set  OwnerSplitCity =PARSENAME(replace(OwnerAddress,',','.'),2)

alter table NACHVILLE 
add OwnerSplitState nvarchar(255);

update NACHVILLE
set  OwnerSplitState =PARSENAME(replace(OwnerAddress,',','.'),1)

-- yes or no repair 

update NACHVILLE
set SoldAsVacant= CASE WHEN SoldAsVacant='N' THEN  'No' 
					   WHEN SoldAsVacant='Y' THEN  'Yes'
				       ELSE SoldAsVacant
				END

-- remove duplicant


with RowNumCTE as (
select * , ROW_NUMBER() over(	partition by ParcelId,PropertyAddress,SalePrice,SaleDate,LegalReference
								order by UniqueId )row_num
from NACHVILLE 
)

delete
from RowNumCTE
where row_num>1


--- remove unused columns

alter table NACHVILLE
drop column PropertyAddress,TaxDistrict