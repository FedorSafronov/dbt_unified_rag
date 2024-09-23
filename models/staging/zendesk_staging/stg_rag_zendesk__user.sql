
with base as (

    {{
        fivetran_utils.union_data(
            table_identifier='user', 
            database_variable='rag_zendesk_database', 
            schema_variable='rag_zendesk_schema', 
            default_database=target.database,
            default_schema='rag_zendesk',
            default_variable='user',
            union_schema_variable='rag_zendesk_union_schemas',
            union_database_variable='rag_zendesk_union_databases'
        )
    }}

),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(source('rag_zendesk','user')),
                staging_columns=get_zendesk_user_columns()
            )
        }}

        {{ fivetran_utils.source_relation(
            union_schema_variable='rag_zendesk_union_schemas', 
            union_database_variable='rag_zendesk_union_databases') 
        }}
        
    from base
),

final as ( 
    
    select 
        id as user_id,
        external_id,
        _fivetran_synced,
        _fivetran_deleted,
        cast(last_login_at as {{ dbt.type_timestamp() }}) as last_login_at,
        cast(created_at as {{ dbt.type_timestamp() }}) as created_at,
        cast(updated_at as {{ dbt.type_timestamp() }}) as updated_at,
        email,
        name,
        organization_id,
        phone,
        role,
        ticket_restriction,
        time_zone,
        active as is_active,
        suspended as is_suspended,
        source_relation

    from fields
)

select * 
from final