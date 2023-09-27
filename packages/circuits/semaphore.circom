pragma circom 2.1.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "./tree.circom";

template CalculateSecret() {
    signal input identityNullifier;
    signal input identityTrapdoor;

    signal output identitySecret;

    identitySecret <== Poseidon(2)(identityNullifier, identityTrapdoor);
}

template CalculateIdentityCommitment() {
    signal input identitySecret;

    signal output identityCommitment;

    identityCommitment <== Poseidon(1)(identitySecret);
}

template CalculateNullifierHash() {
    signal input externalNullifier;
    signal input identityNullifier;

    signal output nullifierHash;

    nullifierHash = Poseidon(2)(externalNullifier, identityNullifier);
}

// The current Semaphore smart contracts require nLevels <= 32 and nLevels >= 16.
template Semaphore(nLevels) {
    signal input identityNullifier;
    signal input identityTrapdoor;
    signal input treePathIndices[nLevels];
    signal input treeSiblings[nLevels];

    signal input signalHash;
    signal input externalNullifier;

    signal output root;
    signal output nullifierHash;

    signal identitySecret <== CalculateSecret()(identityNullifier, identityTrapdoor);

    signal identityCommitment <== CalculateIdentityCommitment()(identitySecret);

    nullifierHash <== CalculateNullifierHash()(externalNullifier, identityNullifier);

    // Calculate inclusionProof for n levels
    root <== MerkleTreeInclusionProof(nLevels)(
        identityCommitment,
        treePathIndices,
        treeSiblings
    );

    // Dummy square to prevent tampering signalHash.
    signal signalHashSquared;
    signalHashSquared <== signalHash * signalHash;

}

component main {public [signalHash, externalNullifier]} = Semaphore(20);
