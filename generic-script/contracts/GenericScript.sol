// Copyright (C) 2020 Cartesi Pte. Ltd.

// SPDX-License-Identifier: GPL-3.0-only
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.

// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
// PARTICULAR PURPOSE. See the GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// Note: This component currently has dependencies that are licensed under the GNU
// GPL, version 3, and so you should treat this component as a whole as being under
// the GPL version 3. But all Cartesi-written code in this component is licensed
// under the Apache License, version 2, or a compatible permissive license, and can
// be used independently under the Apache v2 license. After this component is
// rewritten, the entire component will be released under the Apache v2 license.

/// @title GenericScript
/// @author Milton Jonathan
pragma solidity ^0.7.0;
pragma experimental ABIEncoderV2;

import "@cartesi/descartes-sdk/contracts/DescartesInterface.sol";


contract GenericScript {

    DescartesInterface descartes;

    bytes32 templateHash = 0xb20cc59994cfd21b21ebb07234d8d4b5016efa60d53854198b3e088b310eb5c0;
    uint64 outputPosition = 0xa000000000000000;
    uint8 outputLog2Size = 10;
    uint256 finalTime = 1e11;
    uint256 roundDuration = 51;

    // generic script to execute
    bytes script = "#!/usr/bin/lua\n\
        function fact (n)\n\
            if n <= 0 then\n\
                return 1\n\
            else\n\
                return n * fact(n-1)\n\
            end\n\
        end\n\
        print(fact(20))\n\
    ";

    // defines script size as 1024 bytes
    uint8 scriptLog2Size = 10;

    constructor(address descartesAddress) {
        descartes = DescartesInterface(descartesAddress);
    }

    function instantiate(address[] memory parties) public returns (uint256) {

        // specifies an input drive containing the script
        DescartesInterface.Drive[] memory drives = new DescartesInterface.Drive[](1);
        drives[0] = DescartesInterface.Drive(
            0x9000000000000000,    // 2nd drive position: 1st is the root file-system (0x8000..)
            scriptLog2Size,        // driveLog2Size
            script,                // directValue
            "",                    // loggerIpfsPath
            0x00,                  // loggerRootHash
            parties[0],            // provider
            false,                 // waitsProvider
            false                  // needsLogger
        );

        // instantiates the computation
        return descartes.instantiate(
            finalTime,
            templateHash,
            outputPosition,
            outputLog2Size,
            roundDuration,
            parties,
            drives
        );
    }

    function getResult(uint256 index) public view returns (bool, bool, address, bytes memory) {
        return descartes.getResult(index);
    }

    function destruct(uint256 index) public {
        descartes.destruct(index);
    }
}
