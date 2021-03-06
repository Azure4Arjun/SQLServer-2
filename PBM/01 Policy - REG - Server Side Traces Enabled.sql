Declare @condition_id int
EXEC msdb.dbo.sp_syspolicy_add_condition @name=N'REG - Server Side Traces Enabled', @description=N'', @facet=N'Server', @expression=N'<Operator>
  <TypeClass>Bool</TypeClass>
  <OpType>EQ</OpType>
  <Count>2</Count>
  <Function>
    <TypeClass>Numeric</TypeClass>
    <FunctionType>ExecuteSql</FunctionType>
    <ReturnType>Numeric</ReturnType>
    <Count>2</Count>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>numeric</Value>
    </Constant>
    <Constant>
      <TypeClass>String</TypeClass>
      <ObjType>System.String</ObjType>
      <Value>SELECT &lt;?char 13?&gt;
	CASE&lt;?char 13?&gt;
	WHEN COUNT (DISTINCT traceid) = 0&lt;?char 13?&gt;
	THEN 1&lt;?char 13?&gt;
		WHEN COUNT (DISTINCT traceid) = 1&lt;?char 13?&gt;
	THEN 0&lt;?char 13?&gt;
		WHEN COUNT (DISTINCT traceid) &gt; 1&lt;?char 13?&gt;
	THEN 2&lt;?char 13?&gt;
	END&lt;?char 13?&gt;
FROM sys.fn_trace_getinfo(0)</Value>
    </Constant>
  </Function>
  <Constant>
    <TypeClass>Numeric</TypeClass>
    <ObjType>System.Double</ObjType>
    <Value>0</Value>
  </Constant>
</Operator>', @is_name_condition=0, @obj_name=N'', @condition_id=@condition_id OUTPUT
Select @condition_id


Declare @object_set_id int
EXEC msdb.dbo.sp_syspolicy_add_object_set @object_set_name=N'policy_ObjectSet_5', @facet=N'Server', @object_set_id=@object_set_id OUTPUT
Select @object_set_id

Declare @target_set_id int
EXEC msdb.dbo.sp_syspolicy_add_target_set @object_set_name=N'policy_ObjectSet_5', @type_skeleton=N'Server', @type=N'SERVER', @enabled=True, @target_set_id=@target_set_id OUTPUT
Select @target_set_id




Declare @policy_id int
EXEC msdb.dbo.sp_syspolicy_add_policy @name=N'REG - Server Side Traces Enabled', @condition_name=N'REG - Server Side Traces Enabled', @policy_category=N'Regular Health Check', @description=N'', @help_text=N'', @help_link=N'', @schedule_uid=N'00000000-0000-0000-0000-000000000000', @execution_mode=0, @is_enabled=False, @policy_id=@policy_id OUTPUT, @root_condition_name=N'', @object_set=N'policy_ObjectSet_5'
Select @policy_id


