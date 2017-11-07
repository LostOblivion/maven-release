package no.kantega.olasol.mavenrelease;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

class ExampleTest {

    private Example example;

    @BeforeEach
    void setup() {
        example = new Example();
    }

    @Test
    void printsHelloWorld() {
        example.printHelloWorld();
    }
}
