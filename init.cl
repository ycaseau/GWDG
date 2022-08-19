(printf("--- load init Duncan Watts Simulation -- \n"))

*where* :: "c:\\proj\\gwdg"

(debug(),
 verbose() := 3,
 source(compiler) := *where* / "wk\\obj",
// overflow?(compiler) := true,                // we need this ! > otherwise random bugs occur
 safety(compiler) := 5)                        // ensure safe compiling + remove warnings


// module - Yves's version

// reference version - cf. SSOCC document
gw1 :: module(part_of = claire,
              source = *where* / "v0.1",
              uses = list(Reader),
              made_of = list("model","interface","simul"))

