/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateconverted, CONVERT( date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
set SaleDate = CONVERT( date,SaleDate)

alter table nashvillehousin
add SaleDateconverted Date;

update NashvilleHousing
set SaleDateconverted = CONVERT( date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
isnull (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]


update a
set PropertyAddress =  isnull (a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


------------------------------------
--------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select
substring (PropertyAddress, 1, CHARINDEX( ',', PropertyAddress )-1) as address, 
substring (PropertyAddress, CHARINDEX( ',', PropertyAddress ) +1, len(PropertyAddress)) as address
From PortfolioProject.dbo.NashvilleHousing


alter table nashvillehousing
add Propertysplitaddress nvarchar(255);

update NashvilleHousing
set Propertysplitaddress =substring (PropertyAddress, 1, CHARINDEX( ',', PropertyAddress )-1)



alter table nashvillehousing
add Propertysplitcity nvarchar(255);

update NashvilleHousing
set Propertysplitcity =substring (PropertyAddress, CHARINDEX( ',', PropertyAddress ) +1, len(PropertyAddress))

select*
from PortfolioProject.dbo.NashvilleHousing



select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

select
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing



alter table nashvillehousing
add Ownersplitaddress nvarchar(255);

update NashvilleHousing
set Ownersplitaddress =PARSENAME(replace(OwnerAddress,',','.'),3)

alter table nashvillehousing
add Ownersplitcity nvarchar(255);

update NashvilleHousing
set Ownersplitcity =PARSENAME(replace(OwnerAddress,',','.'),2)

alter table nashvillehousing
add Ownersplitstate nvarchar(255);

update NashvilleHousing
set Ownersplitstate =PARSENAME(replace(OwnerAddress,',','.'),1)

select*
from PortfolioProject.dbo.NashvilleHousing

--Where PropertyAddress is null
--order by ParcelID


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject.dbo.NashvilleHousing



update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end



--Remove Duplicates
with rownumCTE as(
select*,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
                 SaleDate,
				 SalePrice,
				 LegalReference
	             order by
				 UniqueID
				 ) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select *
from rownumCTE
where row_num > 1
--order by PropertyAddress


select*
from PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------------------------------------------------------

--order by ParcelID



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns




select*
from PortfolioProject.dbo.NashvilleHousing

alter table PortfolioProject.dbo.NashvilleHousing
drop column PropertyAddress, TaxDistrict, OwnerAddress


alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















