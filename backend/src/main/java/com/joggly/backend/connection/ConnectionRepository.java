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

    @Query("""
            select count(c) > 0 from Connection c
            where c.status = 'ACCEPTED'
              and ((c.requester.id = :userA and c.recipient.id = :userB)
                or (c.requester.id = :userB and c.recipient.id = :userA))
            """)
    boolean existsAcceptedBetween(@Param("userA") UUID userA, @Param("userB") UUID userB);

    /** The other party's id for each of this user's accepted connections - i.e. their running buddies. */
    @Query("""
            select case when c.requester.id = :userId then c.recipient.id else c.requester.id end
            from Connection c
            where c.status = 'ACCEPTED'
              and (c.requester.id = :userId or c.recipient.id = :userId)
            """)
    List<UUID> findAcceptedConnectionUserIds(@Param("userId") UUID userId);
}
