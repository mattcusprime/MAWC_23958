DECLARE @xml xml = N'<root>
  <Identity docID="5F2758A2-673E-40D0-833B-469010EB085B" DocumentType="ActionType" CreatedOn="2018-11-28T17:26:22.2415165" CreatedBy="HO\vohlto" SourceComputer="LP-TOBIAS" SourceApplication="inResponse.Workers.BlobToFile" Version="6.0.0" Language="us_english" LanguageAlias="English" />
  <ActionTypes>
    <ActionType acttIDSystem="35" Description="Stored Procedure.NET" DLLname=".NET(inResponse.Workers.SP,inResponse.Workers.All)" MaxThreads="1" SubTypeTable="ActionStoredProcedures" DefaultActionTimeout="0">
      <Class actcID="14" actcCode="inResponse.Workers.SP,inResponse.Workers.All" actcDescription="Stored Procedure Processor" actctID="1" />
      <Action Description="Assign Sales Order to Production Order" orgID="14" Comment="This Action will Assign Sales Order Items unto Production Order automatically for the selected list of Sales Orders in the grid" IsLogged="1" SuppressPromptForm="0">
        <StoredProcedure Schema="dbo" Object="spAPP_utlAssignSalesOrdersToProductionDateByAlgID_MWC" />
        <PromptForm>
&lt;RADIOGROUP name="getMode" field="Mode" text="Action" items=" Add to Existing,1; Add to New,2; Remove,3 ; Move to Existing,4" height="100" width="410"  columns="1"/&gt;


&lt;CASE name="Case_getMode"  border="false" labelwidth="150" width="400" 
      master="getMode" masterfieldname="Mode" casenull="LabelNull" caseelse="LabelElse"&gt;


&lt;DATEEDIT name="Show_proddate" field="proddate" caption="New Production Date:" required="true" case="2"/&gt;

&lt;LOOKUPCOMBOBOX name="Show_ProdDateExisting" caption="Existing Production Order:" field="ProdDateExisting" case="1"
    listsource="
declare @FirmStatus int = (select s.setValue from dbo.Settings s where s.setName = N''FirmedProductionOrderStatusValue'')
select
prd.prdProdDate
from dbo.ProductionOrders prd
join dbo.Status stt_prd on stt_prd.sttID=prd.sttID
where stt_prd.sttValue &amp;lt; @FirmStatus
group by prd.prdProdDate"
   listfieldnames="prdProdDate" keyfieldname="prdProdDate" required="true"/&gt;



&lt;LOOKUPCOMBOBOX name="Show_ProdDateExisting2" caption="Existing Production Order:" field="ProdDateExisting" case="4"
    listsource="
declare @FirmStatus int = (select s.setValue from dbo.Settings s where s.setName = N''FirmedProductionOrderStatusValue'')
select
prd.prdProdDate
from dbo.ProductionOrders prd
join dbo.Status stt_prd on stt_prd.sttID=prd.sttID
where stt_prd.sttValue &amp;lt; @FirmStatus
group by prd.prdProdDate"
   listfieldnames="prdProdDate" keyfieldname="prdProdDate" required="true"/&gt;

&lt;/CASE&gt;


&lt;CASE name="Case_getMode2" labelwidth="150" width="400"  border="false"
      master="getMode" masterfieldname="Mode" casenull="LabelNull" caseelse="LabelElse"&gt;




&lt;LOOKUPCOMBOBOX name="prdProdBatch" caption="Batch:" field="prdProdBatch" case="1"
    listsource="
DECLARE @ProdDate AS nvarchar(50) = :prdProdDate

select 
prd.prdProdBatch
,prdDescription
from dbo.ProductionOrders prd
where prd.prdProdDate =Cast (@ProdDate as Date)
order by prd.prdProdBatch"
            listmaster="Show_ProdDateExisting" listmasterfieldnames="prdProdDate"
                                                    
    listfieldnames="prdProdBatch" keyfieldname="prdProdBatch"  required="true"/&gt;

                

                                       


&lt;LOOKUPCOMBOBOX name="prdProdBatch2" caption="Batch:" field="prdProdBatch" case="4"
    listsource="
DECLARE @ProdDate AS nvarchar(50) = :prdProdDate

select 
prd.prdProdBatch
,prdDescription
from dbo.ProductionOrders prd

where prd.prdProdDate =Cast (@ProdDate as Date)
order by prd.prdProdBatch"
            listmaster="Show_ProdDateExisting" listmasterfieldnames="prdProdDate"

    listfieldnames="prdProdBatch" keyfieldname="prdProdBatch" required="true"/&gt;



&lt;/CASE&gt;
      
</PromptForm>
        <Parameter Parameter="Mode" ParameterDescription="Operation Mode." Description="Operation Mode." DefaultValue="1" IsRequired="0" Sequence="5" />
        <Parameter Parameter="prdProdBatch" ParameterDescription="prdProdBatch" Description="prdProdBatch" IsRequired="0" Sequence="3" />
        <Parameter Parameter="proddate" ParameterDescription="proddate" Description="proddate" IsRequired="1" Sequence="1" />
        <Parameter Parameter="ProdDateExisting" ParameterDescription="ProdDateExisting" Description="ProdDateExisting" IsRequired="0" Sequence="4" />
        <FAP Mode="1" />
        <Form FormCode="Sales Orders" RunButton="Qk02CQAAAAAAADYAAAAoAAAAGAAAABgAAAABACAAAAAAAAAJAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJhzc5SceXnGlW9vupJsbK2TbGygkm1tlJRtbYiVbm57k2pqb5RtbWKUa2tWlmxsSZJpaT2aamowjmNjJJtvbxeVamoMqlVVAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAJNvb7P77Oz/9uXl//Ti4v/z3uD/+trk/8ertf/VvMD/28XF/9W8vP/Qt7f/up+f/8iqqv/AoaH/vJub/7iVlf+ohIT+sImJ+rWIiPGzgoLlsoCA2Kdvb5YAAAAAAAAAAJVxcbD05OT/7t3d//Pf4f/Y18j/I6sv/xCeFP+rtJz/3srO//Lf3//z4OD/0MHB//Lf3//v3Nz/8Nzc//Hd3f/Qvr7/8dzc/+/a2v/u2dn/9N/f/5dmZrsAAAAAAAAAAJJxca325eX/79/f//ni6P9hxHD/MNNm/x/ARv8uoi3/4MfP//He3v/w3t7/z8DA//Dd3f/s2dn/7NjY/+7a2v/Nu7v/7djY/+rT0//p0tL/8NnZ/5ZmZrsAAAAAAAAAAJJzc6n25+f/8+Tk//rj5/+f1Kf/N+Nz/xrGS/91unL/+OHn//Hj5P/04+T/08PD//Hf3//v29v/7dra//Db3P/Rvr//9dvf//DX2f/t1tb/8Nzc/5ZlZbsAAAAAAAAAAJN0dKfUyMj/1MfH/9bIyf/gy9D/sMSs/5SvkP/p0tv/4dbc/9O2rP/EuLv/tKmq/+TT0//i0dH/4tDQ/+jS1P/Gt7T/lLuG/7Ouo//Qub3/7djZ/5VoaLsAAAAAAAAAAJF1daTz5+f/8uTk//Dj4//v4uL/9OLk/9LExv/w5+3/w3Ix/71MAP+uRwD/p52g/+LU1P/k1NT/49LS/+zS2P8YsDD/D7cz/wCfAf+vp5//3srL/5ZqarsAAAAAAAAAAJN4eKD05+f/8+jo//Ln5//y5eX/9ejo/9XKyv/37/b/zmwJ/+6mW/+9SwD/sJmR//Tl5v/x4OD/8d/g/+vc2f8gzVX/TeqH/wSwJP+csIz/9+Dj/5ZqarsAAAAAAAAAAJF6ep3y6Oj/9Ojo//Pn5//z5+f/9ujo/9XLy//16+7/5sCi/9eDMf/ZnG7/18/U//Tl5f/x4+b/9Onv/+nY4/96u4n/Nsti/2jAbv/42+H/9OHh/5ZpabsAAAAAAAAAAJJ7e5r06Oj/9+zs//bs7P/37/L/+fDx/9rQ0P/57e3//+73///t/v/u2+j/zsLD//fq6//q08z/t1ME/69HAP+yj4n/6c/Z//vf5f/v29z/9OLi/5ZqarsAAAAAAAAAAJJ+fpjj2tr/59/g/+nk6P/XrJL/waKT/66rrv/u3uT/iMiH/wKiD/8ypTD/r6Ck/+PY3f/QkFv/34kv/89rCP+oXi3/08nN/+PR0f/i0ND/59fX/5VqarsAAAAAAAAAAJKAgJPg19f/6OTo/8qHUv/GWgD/tkMA/6eFdf/i09r/D7s5/zrWb/8IsST/a5dj/+XX3P/lyr3/3YYu/8xkAf/CoI//6tve/+XV1f/l1NT/7Nvb/5hvb74AAAAAAAAAAJR/f5Hy6en/+/f9/9qUUP/vp1z/xVkA/7mPdf//8vv/TtB0/znhc/8OtC//ub2v//rr7f/06Or/8unu//Tr7//Xy83/8+Pk//Lk5v/v3+H/9+bm/5dxcb8AAAAAAAAAAJGDg47x6en/+fP1//ft7f/gpGz/36yC/97b4f/88fP//e3x/73fv//r6OL/39DT//bq6v/z5ub/8+bm//Xm5v/Xysv/8eHi/8uUdP++m43/1MrO/5ZwcL8AAAAAAAAAAJSHh4rw6Oj/+/X1//r09f/9+f7///v//9/Y2P/68vL/+e/w//vu8f/77u//29DR//3t8f//6vT/7tjh/+rY2//c09n/zXo0/8hfAP+yQAD/yKui/5Bsbb8AAAAAAAAAAJOGhofq5OT/9u/v//3v9v/t5+X/4NPY/8a9wP/w6en/6+Tk/+ri4v/q4eH/08bJ/7rVtP8Rphz/GJ8b/7W1qv+/tr7/1IM2/++nXf/ATgD/wqWX/5p1db8AAAAAAAAAAJOHh4TW0dH/6+Dl/3q9f/8ApxL/AJ4F/5GhjP/b0tX/6OHh/+nh4f/q4eH/3MnR/zrAVv831mv/FLg3/1CnTP/JusH/7tzX/9yeZ//esZT/9uvu/5dzc78AAAAAAAAAAJOHh4Lv6+v//////y7CUf9I5YD/GrxC/1aqVf/26vD/+vPz//nx8f/58PD/5Nba/4LXmP8543X/DLk2/6HGmv/ezdL/8+fo//Lm6f/x4uX/9+fo/5Zxcb8AAAAAAAAAAJONjX3t6en///z//5rfq/8m01//Frk6/7zNuP//9/r/+fHx//fv7//48fH/3tPT///v9f/D38L/1N/N///r8f/Zzc3/9OTk//Dg4P/v39//9ubm/5Zxcb8AAAAAAAAAAI+NjXvs6ur///3+///8///19vH///r9/+bf4f/89vb/+PPz//jx8f/58fH/3dXV//rv8P/67O//+ert//jr7P/bz8//9ujo//Pl5f/y4+P/+erq/5dzc78AAAAAAAAAAJWOjnjx7+///////////////////////+fi4v///f3//PX1//jx8f/16+v/18/P/+3i4v/m2tr/49XV/+DQ0P/IuLj/18XF/9O+vv/QuLj/0Le3/5p0dL8AAAAAAAAAAJiYmGikoqLdop+f1ZyXl86ZlJTFmIyMvpWJibaThISukIGBppGBgZ6Sfn6Wk35+jpN+foaTeHh/knh4d5R5eW6Sd3dnlnZ2X5NycleUcXFPk3NzR5dycjEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" CompleteDialog="0" grmID="0" />
        <Form FormCode="Internal Orders" RunButton="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Uf9I5YD/GrxC/1aqVf/26vD/+vPz//nx8f/58PD/5Nba/4LXmP8543X/DLk2/6HGmv/ezdL/8+fo//Lm6f/x4uX/9+fo/5Zxcb8AAAAAAAAAAJONjX3t6en///z//5rfq/8m01//Frk6/7zNuP//9/r/+fHx//fv7//48fH/3tPT///v9f/D38L/1N/N///r8f/Zzc3/9OTk//Dg4P/v39//9ubm/5Zxcb8AAAAAAAAAAI+NjXvs6ur///3+///8///19vH///r9/+bf4f/89vb/+PPz//jx8f/58fH/3dXV//rv8P/67O//+ert//jr7P/bz8//9ujo//Pl5f/y4+P/+erq/5dzc78AAAAAAAAAAJWOjnjx7+///////////////////////+fi4v///f3//PX1//jx8f/16+v/18/P/+3i4v/m2tr/49XV/+DQ0P/IuLj/18XF/9O+vv/QuLj/0Le3/5p0dL8AAAAAAAAAAJiYmGikoqLdop+f1ZyXl86ZlJTFmIyMvpWJibaThISukIGBppGBgZ6Sfn6Wk35+jpN+foaTeHh/knh4d5R5eW6Sd3dnlnZ2X5NycleUcXFPk3NzR5dycjEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" CompleteDialog="0" grmID="0" />
        <AllowedUserGroup UserGroupCode="Administrators" />
      </Action>
      <Mode atmID="2" Description="Run Local" IsDefault="1" />
      <Mode atmID="3" Description="Run inResponse" IsDefault="0" />
      <Mode atmID="4" Description="Schedule" IsDefault="0" />
    </ActionType>
  </ActionTypes>
</root>'
EXECUTE dbo.spINT_utlMergeActionsXML
    @xml = @xml
GO
