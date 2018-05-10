const ETH = 1000000000000000000;

describe("Hacking Workshop", function() {

    this.timeout(0);
    before(function(done) {
      this.timeout(0);
      var contractsConfig = {
        "SimpleToken": {
          args: []
        },
        "VoteTwoChoices": {
            args: []
        },
        "BuyToken": {
            args: []
        },
        "Store": {
            args: []
        },
        "CountContribution": {
            args: []
        },
        "Token": {
            args: []
        },
        "DiscountedBuy": {
            args: []
        },
        "VaultInvariant": {
            args: []
        },
      };
      EmbarkSpec.deployAll(contractsConfig, () => { done() });
    });

    it("should have a zero or positive balance. Fixes SimpleToken vulnerability", async function() {
        const accounts = await web3.eth.getAccounts();
        await SimpleToken.methods.buyToken().send({
            from: web3.eth.defaultAccount,
            value: 2 * ETH
        });

        try {
            await SimpleToken.methods.sendToken(accounts[1], 4).send({
                from: web3.eth.defaultAccount
            });
            assert.fail();
        }
        catch (err) {
            var isRevert = err.message.indexOf('revert') >= 0;
            assert.equal(isRevert, true);
        }
    });
  
    it("Should not cast 0 votes. Fixes VoteTwoChoices vulnerability", async function() {
        const accounts = await web3.eth.getAccounts();
        await VoteTwoChoices.methods.buyVotingRights().send({
            from: web3.eth.defaultAccount,
            value: 2 * ETH
        });

        try {
            await VoteTwoChoices.methods.vote(0, web3.utils.asciiToHex('1')).send({
                from: web3.eth.defaultAccount
            });
            assert.fail();
        }
        catch (err) {
            var isRevert = err.message.indexOf('revert') >= 0;
            assert.equal(isRevert, true);
        }
    });

    it("Should not have price 0. Fixes BuyToken vulnerability", async function() {
        try {
            await BuyToken.methods.setPrice(0).send({
                from: web3.eth.defaultAccount
            });
            await BuyToken.methods.buyToken(100000000000000, 0).send({
                from: web3.eth.defaultAccount,
                value: 0 * ETH
            });
        }
        catch (err) {
            var isRevert = err.message.indexOf('revert') >= 0;
            assert.equal(isRevert, true);
        }
    });

    it("Should withdraw from safe. Store contract", async function() {

        await Store.methods.store().send({
            from: web3.eth.defaultAccount,
            value: 1 * ETH
        });
        await Store.methods.take().send({
            from: web3.eth.defaultAccount
        });
    });

    it("Should not be possible to call recordContribution. Fixes CountContribution vulnerability", async function() {
        try {
            await CountContribution.methods.recordContribution(web3.eth.defaultAccount, 1000000000000000).send({
                from: web3.eth.defaultAccount
            });
            assert.fail();
        }
        catch (err) {
            var isCorrectError = err.message.indexOf('is not a function') >= 0;
            assert.equal(isCorrectError, true);
        }
    });

    it("Should work. Fixes Token vulnerability", async function() {
        const accounts = await web3.eth.getAccounts();
        await Token.methods.buyToken().send({
            from: accounts[2],
            value: 2 * ETH
        });
        await Token.methods.buyToken().send({
            from: accounts[3],
            value: 2 * ETH
        });
        await Token.methods.sendAllTokens(accounts[2]).send({
            from: accounts[3]
        });
        const balance = 0 + await Token.methods.balances(accounts[2]).call({});
        assert.equal(balance, 4);
    });

    it("Should buy more than 3 times. Fixes DiscounterBuy vulnerability", async function() {
        const accounts = await web3.eth.getAccounts();
    });
  
  });
  