package com.yuryoparin.repository.jdbc;

import com.yuryoparin.model.Complex;
import com.yuryoparin.util.PGobjectAdapter;
import org.postgresql.util.PGobject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.SqlOutParameter;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;

import javax.sql.DataSource;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

/**
 * User: Yury Oparin
 * Date: 09/01/15
 * Time: 18:39
 */
public class ComplexRepository {
    private static final Logger logger = LoggerFactory.getLogger(ComplexRepository.class);

    private final DataSource dataSource;
    private final SimpleJdbcCall call;

    public ComplexRepository(DataSource dataSource) {
        this.dataSource = dataSource;

        call = new SimpleJdbcCall(dataSource)
                    .withoutProcedureColumnMetaDataAccess()
                    .withProcedureName("ArraySum")
                    .withSchemaName("core")
                    .declareParameters(
                            new SqlParameter("_numbers", Types.ARRAY),
                            new SqlOutParameter("retval", Types.BIGINT)
                    );
    }

    /**
     *
     */
    public long summate(Complex[] numbers) throws SQLException {
        java.sql.Array complexArray = null;

        List<PGobject> pGobjects = new ArrayList<>(numbers.length);
        for (Complex c : numbers) {
            pGobjects.add(PGobjectAdapter.getPGobject(c));
        }
        try {
            complexArray = dataSource.getConnection().createArrayOf("complex", pGobjects.toArray());
        } catch (SQLException e) {
            logger.error(e.getMessage(), e);
        }

        MapSqlParameterSource params = new MapSqlParameterSource();
        params.addValue("_numbers", complexArray, Types.ARRAY);

        call.compile();
        return (Long) call.execute(params).get("retval");
    }
}
