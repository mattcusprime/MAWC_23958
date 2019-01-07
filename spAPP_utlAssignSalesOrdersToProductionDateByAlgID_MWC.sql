USE [inSight_MWC_11_1]
GO
/****** Object:  StoredProcedure [dbo].[spAPP_utlAssignSalesOrdersToProductionDateByAlgID_MWC]    Script Date: 12/19/2018 10:11:30 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[spAPP_utlAssignSalesOrdersToProductionDateByAlgID_MWC]
     @algID int
    ,@ProdDate date = null
	,@ProdDateExisting date = null
    ,@prdProdBatch int = null
    ,@Mode tinyint 
   -- ,@DoUnassign bit = 0
    ,@InitialProductionOrderStatusValue int =null
    ,@FirmedProductionOrderStatusValue int = null

AS
-- Version : $Id: spAPP_utlAssignSalesOrdersToProductionDateByAlgID_2020.sql,v 1.1 2012/02/07 00:04:32 US01\jamech Exp $

----- need to update to 9.x 
SET NOCOUNT ON;

SET @InitialProductionOrderStatusValue = (select s.setValue from dbo.Settings s where s.setName = N'InitialProductionOrderStatusValue')
SET @FirmedProductionOrderStatusValue = (select s.setValue from dbo.Settings s where s.setName = N'FirmedProductionOrderStatusValue') 

BEGIN TRY
BEGIN;

declare @jobNumber nvarchar(max);
set @jobNumber = (select top 1 oa.[Job Number] from alg.orders alg join dbo.vwOrderAttributeValues oa on oa.ordIDordAv = alg.ordID where alg.algID = @algID);--added by Matt/Wolfgang
			

    DECLARE @pltID int =68  -- (SELECT TOP (1) pltID FROM dbo.Plant ORDER BY pltPlantCode)
        ,@sttID_InitialProductionOrderStatusValue int = (SELECT sttID FROM dbo.[Status] stt WHERE stt.sttValue = @InitialProductionOrderStatusValue)
        ,@sttID_FirmedProductionOrderStatusValue int = (SELECT sttID FROM dbo.[Status] stt WHERE stt.sttValue = @FirmedProductionOrderStatusValue)
        ,@sttID_Current int
        ,@prdID int
   --     ,@prdProdBatch int
        ,@pdtID int
        ,@SchedOffset int
        ,@OffsetDate datetime
                
    BEGIN TRANSACTION 
 
IF @Mode in (1,2) --- 1 Add to Existing   2 add to New , 4 move 
Begin 
 
    
    IF EXISTS 
    (	
		select *
		FROM dbo.ProductionOrderLineInstances poli
		join dbo.OrderLines oln on oln.olnID = poli.olnID
		join dbo.Orders ord on ord.ordID = oln.ordID
		join ALG.Orders alg on alg.ordID = ord.ordID
		join dbo.ProductionOrders prd on prd.prdid =poli.prdID
		join dbo.[Status] stt on stt.sttID = prd.sttId
		WHERE alg.algID = @algID	
	 )

	BEGIN			   
		RAISERROR (N'Selected Order(s) already had been assigned to a Production Order',0,1)
	END
	ELSE
		iF @Mode = 2 -- new
			and not exists
			(select * from dbo.PlantCalendar ptc
				where ptc.pltID=@pltID 
				and ptc.ptcDate=@ProdDate 
				and ptc.ptcMfgDay = 1
			)
		BEGIN			   
		RAISERROR (N'Selected Date is not a Workday!',0,1)
		END

		---- make sure ProdOrdSerNum is unique
	




	ELSE	
	BEGIN
		---- new production order
		IF @ProdDateExisting is null and @prdProdBatch is null       
		SET @prdProdBatch = isnull((
							select top 1 isnull(prdProdBatch,0) + 1 
							from dbo.ProductionOrders 
							where prdProdDate = @ProdDate
							order by prdProdBatch desc
							),1)

		IF @ProdDateExisting is not null and @Mode =1
			set @ProdDate = @ProdDateExisting




	
		MERGE INTO dbo.ProductionOrders d
		USING 
		(
			SELECT
				 @ProdDate as prdProdDate
				,coalesce (@prdProdBatch,1) as prdProdBatch							
				,@sttID_InitialProductionOrderStatusValue as sttID																																
				,@pltID as pltID
				,@JobNumber as JobNumber --added by Matt/Wolfgang
		) s
		ON s.prdProdDate = d. prdProdDate
		AND s.prdProdBatch = d.prdProdBatch
    
		WHEN MATCHED THEN UPDATE
		SET @sttID_Current = d.sttID
			,@prdID = d.prdID
			--,d.prdProdBatch = @prdProdBatch
			,d.prdDescription=s.JobNumber--added by Matt/Wolfgang
        
		WHEN NOT MATCHED BY TARGET THEN INSERT
			(prdProdDate
			,prdProdBatch
			,sttID
			,pltID
			,prdDescription)--added by Matt/Wolfgang

		VALUES
			(s.prdProdDate
			,@prdProdBatch --s.prdProdBatch
			,s.sttID
			,s.pltID
			,s.JobNumber--added by Matt/Wolfgang
			);
		SET @prdID = ISNULL(@prdID, SCOPE_IDENTITY())

		IF @sttID_Current IS NOT NULL -- only when matched
			IF EXISTS
			(
				SELECT 1
				FROM dbo.ProductionOrders prd
				join dbo.[Status] stt on stt.sttID = prd.sttId
				WHERE stt.sttID = @sttID_Current
				AND stt.sttValue >= @FirmedProductionOrderStatusValue
				and prd.prdID = @prdID
				and prd.prdProdDate = @ProdDate
				and prd.prdProdBatch = @prdProdBatch
			)
				RAISERROR('Selected Production Order already firmed.', 16, 1)
    
		IF NOT EXISTS(SELECT * FROM dbo.ProductionOrderDates WHERE prdID = @prdID)
		BEGIN

			DECLARE crx CURSOR LOCAL FAST_FORWARD FOR 
			SELECT pdtID, pdtSchedOffset 
			FROM dbo.PODetailDates

			OPEN crx

			FETCH NEXT FROM crx INTO @pdtID, @SchedOffset

			WHILE @@FETCH_STATUS = 0
			BEGIN

				exec dbo.spBAS_getMfgDateUsingOffset
				  @PlantID = @pltID,
				  @StartDate = @ProdDate,
				  @Offset = @SchedOffset,
				  @NewDate = @OffsetDate output

				INSERT INTO dbo.ProductionOrderDates(pdtID, prdID, podSchedDateTime)
				VALUES(@pdtID, @prdID, @OffsetDate)

			FETCH NEXT FROM crx INTO @pdtID, @SchedOffset
			END

			CLOSE crx
			DEALLOCATE crx    
     
		END

		------ 1 Add to Existing   2 add to New
		--IF @Mode in (1,2) 

			INSERT INTO [dbo].ProductionOrderLineInstances
				(
				[olnID]
				,[olnIDInstance]
				,[prdID])
			--OUTPUT inserted.*
			SELECT
				 olni.olnID
				 ,olni.olnIDInstance
				 ,@prdID as [prdID]
			FROM dbo.Orders ord
			JOIN dbo.OrderLines oln ON oln.ordID = ord.ordID
			join dbo.orderlineinstances olni on olni.olnid = oln.olnid
			LEFT JOIN dbo.ProductionOrderLineInstances poli	on poli.olnID=olni.olnID
			and poli.olnIDInstance=olni.olnIDInstance
			JOIN ALG.Orders alg ON alg.ordID = ord.ordID
			WHERE alg.algID = @algID
			AND poli.olnID IS NULL
		
		
		

	 END
--added by Matt Temp variable to pass a non null value, passing ordID and algID
DECLARE @tempOrdId int = null
set @tempOrdId = (select top 1 ordID FROM alg.ORDERS where algID = @algID)
EXEC dbo.spAPP_utlUpdateOrderStatus @tempOrdId,@algID,@OrderStatusValue
--added by Matt changing order status
				  
END
 




 IF @Mode = 3 --- 3 unassign
    BEGIN    
    

  
    IF EXISTS 
    (	
		select *
		FROM dbo.ProductionOrderLineInstances poli
		join dbo.OrderLines oln on oln.olnID = poli.olnID
		join dbo.Orders ord on ord.ordID = oln.ordID
		join ALG.Orders alg on alg.ordID = ord.ordID
		join dbo.ProductionOrders prd on prd.prdid =poli.prdID
		join dbo.[Status] stt on stt.sttID = prd.sttId
		WHERE alg.algID = @algID	
		AND stt.sttValue >= @FirmedProductionOrderStatusValue
	 )
	


	BEGIN			   
		RAISERROR (N'Selected Order(s) already had been assigned to a Firm Production Order and can not be removed!',0,1)
	END
	ELSE


        DELETE poli
        FROM dbo.Orders ord
        JOIN dbo.OrderLines oln ON oln.ordID = ord.ordID
		JOIN dbo.ProductionOrderLineInstances poli on poli.olnID=oln.olnID
        JOIN ALG.Orders alg ON alg.ordID = ord.ordID
        WHERE alg.algID = @algID
     --   AND prdo.prdID = @prdID
    END



	IF @mode = 4 --- MOVE

	
	BEGIN

  IF EXISTS 
    (	
		select *
		FROM dbo.ProductionOrderLineInstances poli
		join dbo.OrderLines oln on oln.olnID = poli.olnID
		join dbo.Orders ord on ord.ordID = oln.ordID
		join ALG.Orders alg on alg.ordID = ord.ordID
		join dbo.ProductionOrders prd on prd.prdid =poli.prdID
		join dbo.[Status] stt on stt.sttID = prd.sttId
		WHERE alg.algID = @algID	
		AND stt.sttValue >= @FirmedProductionOrderStatusValue
						
	 )
	
	BEGIN			   
		RAISERROR (N'Selected Order(s) already had been assigned to a Firm Production Order and can not be moved!',0,1)
	END
	ELSE




	set @prdID =
		(
		select prdID from dbo.ProductionOrders
		 where prdProdDate=@ProdDateExisting
			and prdProdBatch=@prdProdBatch
			and pltID=@pltID
		)


	update poli
	set prdID = @prdID
			FROM dbo.Orders ord
			JOIN dbo.OrderLines oln ON oln.ordID = ord.ordID
			JOIN dbo.ProductionOrderLineInstances poli on poli.olnID=oln.olnID
			JOIN ALG.Orders alg ON alg.ordID = ord.ordID
			WHERE alg.algID = @algID
		
	END

    
  --  BEGIN
		--UPDATE prd
		--SET prd.sttID = @sttID_FirmedProductionOrderStatusValue
		--FROM dbo.ProductionOrders prd
		--WHERE prd.prdID = @prdID 
		--AND (prd.sttID < @sttID_FirmedProductionOrderStatusValue or prd.sttID > @sttID_FirmedProductionOrderStatusValue) -- and their status is different
  --  END

    COMMIT TRANSACTION

END
END TRY
BEGIN CATCH
BEGIN
    -- Call SQL Error Handler
    EXECUTE dbo.spAPP_utlSQLErrorHandler

    IF CURSOR_STATUS ( 'local' , 'crx' ) = 1 BEGIN
        CLOSE crx
        DEALLOCATE crx
    END        
    RETURN -100
END
END CATCH;
