

for j in range(jNum):
    jInfo.append(p.getJointInfo(V60, j))
    print(
    '\n >====================================================================================================== \n')
    print('numJoints = ', jNum, '\n')
    for j in range(jNum):
        jName = jInfo[j][1]
        lName = jInfo[j][12]
        Pos = p.getJointState(V60, j)
        print('joint {} = {}'.format(j, jName))
        print('link  {} = {}'.format(j, lName))
        print('Position  {} = {}\n-'.format(j, jPos))
        print(
        '\n >====================================================================================================== \n')
