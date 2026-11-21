package com.joggly.backend.connection;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ConnectionRepository extends JpaRepository<Connection, UUID> {

    @Query("""
            select c from Connection c
            where (c.requester.id = :userA and c.recipient.id = :userB)
               or (c.requester.id = :userB and c.recipient.id = :userA)
            """)
    Optional<Connection> findBetween(@Param("userA") UUID userA, @Param("userB") UUID userB);

    @Query("""
            select c from Connection c
            where c.requester.id = :userId or c.recipient.id = :userId
            """)
    List<Connection> findAllForUser(@Param("userId") UUID userId);
}
