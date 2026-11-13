/**
* BL-1711: .cfconfig mail settings must map to/from modules.mail.settings
*/
component extends="tests.BaseTest" appMapping="/tests" {

	function run(){

		describe( "BoxLang 1 mail settings", function(){

			var mailDir   = expandPath( '/tests/resources/boxlang1/mail' );
			var noMailDir = expandPath( '/tests/resources/boxlang1/nomail' );

			function freshDir( required string name ) {
				var dir = expandPath( '/tests/resources/tmp/' & name );
				if( directoryExists( dir ) ) { directoryDelete( dir, true ); }
				directoryCreate( dir, true, true );
				return dir;
			}

			it( "can read config", function() {
				var cfg = getInstance( 'BoxLang1@cfconfig-services' ).read( mailDir );
				expect( cfg.getMemento() ).toBeStruct();
			});

			it( "reads modules.mail.settings into CFConfig mail keys", function() {
				var cfg = getInstance( 'BoxLang1@cfconfig-services' ).read( mailDir );
				expect( cfg.getMailDefaultEncoding() ).toBe( 'UTF-8' );
				expect( cfg.getMailSpoolEnable() ).toBeTrue();
				expect( cfg.getMailSpoolInterval() ).toBe( 30 );
				expect( cfg.getMailConnectionTimeout() ).toBe( 60 );
			});

			it( "writes CFConfig mail keys into modules.mail.settings", function() {
				var outDir = freshDir( 'boxlang-mail' );

				getInstance( 'BoxLang1@cfconfig-services' )
					.setMailSpoolEnable( true )
					.setMailSpoolInterval( 45 )
					.setMailConnectionTimeout( 90 )
					.setMailDefaultEncoding( 'UTF-8' )
					.write( outDir );

				var outFile = outDir & '/boxlang.json';
				expect( fileExists( outFile ) ).toBeTrue();
				var written = deserializeJSON( fileRead( outFile ) );

				expect( written.modules.mail.settings.spoolEnable ).toBeTrue();
				expect( written.modules.mail.settings.spoolInterval ).toBe( 45 );
				expect( written.modules.mail.settings.connectionTimeout ).toBe( 90 );
				expect( written.modules.mail.settings.defaultEncoding ).toBe( 'UTF-8' );
				expect( written ).notToHaveKey( 'mailSpoolEnable' );
				expect( written ).notToHaveKey( 'mailSpoolInterval' );
			});

			it( "round-trips mail settings without losing data", function() {
				var outDir = freshDir( 'boxlang-roundtrip' );

				getInstance( 'BoxLang1@cfconfig-services' ).read( mailDir ).write( outDir );
				var reread = getInstance( 'BoxLang1@cfconfig-services' ).read( outDir );

				expect( reread.getMailSpoolEnable() ).toBeTrue();
				expect( reread.getMailSpoolInterval() ).toBe( 30 );
				expect( reread.getMailConnectionTimeout() ).toBe( 60 );
				expect( reread.getMailDefaultEncoding() ).toBe( 'UTF-8' );
			});

			it( "does not error when the config has no mail module settings", function() {
				var cfg = getInstance( 'BoxLang1@cfconfig-services' ).read( noMailDir );
				expect( cfg.getMemento() ).toBeStruct();
			});

			it( "preserves other module settings when writing mail settings", function() {
				var outDir = freshDir( 'boxlang-preserve' );

				getInstance( 'BoxLang1@cfconfig-services' )
					.read( mailDir )
					.setMailSpoolInterval( 99 )
					.write( outDir );

				var written = deserializeJSON( fileRead( outDir & '/boxlang.json' ) );
				expect( written.modules ).toHaveKey( 'compat-cfml' );
				expect( written.modules.mail.settings.spoolInterval ).toBe( 99 );
			});

		});

	}

}

